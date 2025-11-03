import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_providers.dart';
import '../state/post_state.dart';
import '../widgets/media_selector.dart';
import '../widgets/tag_input.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  List<XFile> selectedImages = [];
  List<XFile> selectedVideos = [];
  String? videoThumbnailPath;
  List<String> selectedTags = [];
  bool isLoading = false;
  double uploadProgress = 0.0;
  String uploadStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user == null || user.uid.isEmpty) {
        _showAuthenticationDialog();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _showAuthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Acceso Denegado'),
        content: const Text('Debes iniciar sesión para crear publicaciones.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showMediaSelector() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaSelectorWidget(
        onMediaSelected: (images, videos, thumbnailPath) {
          setState(() {
            selectedImages = images;
            selectedVideos = videos;
            videoThumbnailPath = thumbnailPath;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTagInput() {
    showDialog(
      context: context,
      builder: (context) => TagInputWidget(
        onTagsAdded: (tags) {
          setState(() {
            selectedTags = tags;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _createPost() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es requerido')),
      );
      return;
    }

    if (titleController.text.length > 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede exceder 80 caracteres')),
      );
      return;
    }

    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción es requerida')),
      );
      return;
    }

    if (contentController.text.length > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La descripción no puede exceder 300 caracteres')),
      );
      return;
    }

    if (selectedImages.isEmpty && selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una imagen o video')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);

    if (user == null || user.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      uploadProgress = 0.0;
      uploadStatus = 'Preparando archivos...';
    });

    try {
      final profileAsync = ref.read(profileStreamProvider);

      setState(() {
        uploadStatus = 'Cargando perfil...';
      });

      final profile = await profileAsync.when(
        data: (profile) async => profile,
        loading: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          final retryAsync = ref.read(profileStreamProvider);
          return await retryAsync.when(
            data: (p) async => p,
            loading: () async => null,
            error: (e, s) async => null,
          );
        },
        error: (error, stack) async => null,
      );

      final name = profile?.name ?? '';
      final lastName = profile?.lastName ?? '';
      final alias = profile?.alias;

      final userName = '$name $lastName'.trim();
      final finalAlias = alias != null && alias.isNotEmpty ? alias : null;

      final userProfileImage = profile?.profileImageUrl != null && profile!.profileImageUrl!.isNotEmpty
          ? profile.profileImageUrl
          : null;

      print('[v0] Profile data - name: $name, lastName: $lastName, alias: $alias');
      print('[v0] Creating post with userName: $userName, finalAlias: $finalAlias, userProfileImage: $userProfileImage');

      setState(() {
        uploadStatus = 'Subiendo archivos...';
        uploadProgress = 0.1;
      });

      ref.read(postNotifierProvider.notifier).createPost(
        userId: user.uid,
        title: titleController.text,
        content: contentController.text,
        latitude: 0.0,
        longitude: 0.0,
        address: '',
        images: selectedImages.map((e) => e.path).toList(),
        imageFilePaths: selectedImages.map((e) => e.path).toList(),
        videoFilePaths: selectedVideos.map((e) => e.path).toList(),
        tags: selectedTags,
        userName: userName.isNotEmpty ? userName : 'Usuario',
        alias: finalAlias,
        userProfileImage: userProfileImage,
      );
    } catch (e) {
      print('[v0] Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear publicación: $e')),
      );
      setState(() {
        isLoading = false;
        uploadProgress = 0.0;
        uploadStatus = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PostState>(postNotifierProvider, (previous, next) {
      if (next is PostCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post creado exitosamente')),
        );
        context.pop();
      } else if (next is PostError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        setState(() {
          isLoading = false;
          uploadProgress = 0.0;
          uploadStatus = '';
        });
      }
    });

    final postState = ref.watch(postNotifierProvider);
    if (postState is PostLoading) {
      isLoading = true;
    }

    final totalMedia = selectedImages.length + selectedVideos.length;
    final hasMedia = totalMedia > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showMediaSelector,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[50],
                    ),
                    child: hasMedia
                        ? Stack(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: totalMedia,
                          itemBuilder: (context, index) {
                            if (index < selectedImages.length) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(selectedImages[index].path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (videoThumbnailPath != null)
                                      Image.file(
                                        File(videoThumbnailPath!),
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.videocam,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Agregar fotos o video',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Máximo 4 archivos • Videos hasta 30 MB',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    hintText: 'Escribe un título llamativo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                    counterText: '${titleController.text.length}/80',
                  ),
                  maxLength: 80,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Cuéntanos más sobre esta publicación...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    counterText: '${contentController.text.length}/300',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 300,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _showTagInput,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_offer, size: 20, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Etiquetas (${selectedTags.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.add, size: 20, color: Colors.blue[700]),
                          ],
                        ),
                        if (selectedTags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedTags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    selectedTags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'Agrega etiquetas para que más personas encuentren tu publicación',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Publicar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading && uploadProgress > 0)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          uploadStatus,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (uploadProgress > 0.1) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: uploadProgress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue[700]!,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(uploadProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
