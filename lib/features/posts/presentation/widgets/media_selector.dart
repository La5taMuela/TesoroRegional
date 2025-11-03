import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class MediaSelectorWidget extends StatefulWidget {
  final Function(List<XFile> images, List<XFile> videos, String? thumbnailPath) onMediaSelected;

  const MediaSelectorWidget({
    Key? key,
    required this.onMediaSelected,
  }) : super(key: key);

  @override
  State<MediaSelectorWidget> createState() => _MediaSelectorWidgetState();
}

class _MediaSelectorWidgetState extends State<MediaSelectorWidget> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  List<XFile> selectedVideos = [];
  String? videoThumbnailPath;
  bool isGeneratingThumbnail = false;

  static const int maxMediaFiles = 4;
  static const int maxVideoSizeBytes = 30 * 1024 * 1024;

  Future<void> _pickImages() async {
    final remainingSlots = maxMediaFiles - (selectedImages.length + selectedVideos.length);
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 4 archivos multimedia por publicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final imagesToAdd = images.take(remainingSlots).toList();

        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solo se agregaron $remainingSlots de ${images.length} imágenes (límite de 4 archivos)'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        setState(() {
          selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seleccionando imágenes: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    final totalMedia = selectedImages.length + selectedVideos.length;
    if (totalMedia >= maxMediaFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 4 archivos multimedia por publicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        // Check video size
        final file = File(video.path);
        final fileSize = await file.length();

        if (fileSize > maxVideoSizeBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El video debe ser menor a 30 MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          isGeneratingThumbnail = true;
        });

        // Generate thumbnail
        try {
          final tempDir = await getTemporaryDirectory();
          final thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: video.path,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 512,
            quality: 75,
          );

          setState(() {
            selectedVideos.add(video);
            videoThumbnailPath = thumbnailPath;
            isGeneratingThumbnail = false;
          });
        } catch (e) {
          print('[v0] Error generating thumbnail: $e');
          setState(() {
            selectedVideos.add(video);
            isGeneratingThumbnail = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seleccionando video: $e')),
        );
      }
      setState(() {
        isGeneratingThumbnail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMedia = selectedImages.length + selectedVideos.length;
    final hasMedia = totalMedia > 0;
    final canAddMore = totalMedia < maxMediaFiles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agregar Multimedia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '$totalMedia/4',
                style: TextStyle(
                  fontSize: 16,
                  color: totalMedia >= maxMediaFiles ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isGeneratingThumbnail)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Generando vista previa del video...'),
                ],
              ),
            ),

          if (hasMedia && !isGeneratingThumbnail)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: totalMedia,
                itemBuilder: (context, index) {
                  // Show images first, then video
                  if (index < selectedImages.length) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedImages[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Video thumbnail
                    final videoIndex = index - selectedImages.length;
                    return Stack(
                      children: [
                        ClipRRect(
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
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVideos.removeAt(videoIndex);
                                videoThumbnailPath = null;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (canAddMore && !isGeneratingThumbnail) ? _pickImages : null,
                  icon: const Icon(Icons.image),
                  label: const Text('Imágenes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (selectedVideos.isEmpty && canAddMore && !isGeneratingThumbnail) ? _pickVideo : null,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          if (selectedVideos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Máximo 1 video por publicación',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (hasMedia && !isGeneratingThumbnail)
                  ? () {
                widget.onMediaSelected(selectedImages, selectedVideos, videoThumbnailPath);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
