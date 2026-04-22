// ===========================
// TESORO REGIONAL — JS
// ===========================

// Nav scroll effect
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('scrolled', window.scrollY > 40);
});

// Hamburger menu
const hamburger = document.getElementById('hamburger');
const navLinks = document.querySelector('.nav__links');
hamburger?.addEventListener('click', () => {
  navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
  navLinks.style.flexDirection = 'column';
  navLinks.style.position = 'absolute';
  navLinks.style.top = '70px';
  navLinks.style.right = '20px';
  navLinks.style.background = 'rgba(253,250,243,0.98)';
  navLinks.style.padding = '1.5rem';
  navLinks.style.borderRadius = '12px';
  navLinks.style.boxShadow = '0 8px 32px rgba(44,31,14,0.15)';
  navLinks.style.backdropFilter = 'blur(12px)';
});

// Scroll reveal
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      setTimeout(() => entry.target.classList.add('visible'), i * 80);
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll(
  '.feature-card, .how__step, .mission-card, .testi-card, .section-header'
).forEach(el => {
  el.classList.add('reveal');
  observer.observe(el);
});

// Mission bar animation on scroll
const missionObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.querySelectorAll('.mission-card__bar-fill').forEach(bar => {
        const target = bar.dataset.width || '0%';
        bar.style.width = target;
      });
    }
  });
}, { threshold: 0.3 });
document.querySelectorAll('.mission-card').forEach(card => missionObserver.observe(card));

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth' });
      // Close mobile nav if open
      if (window.innerWidth < 768) navLinks.style.display = 'none';
    }
  });
});

// Parallax orbs on hero
const orbs = document.querySelectorAll('.hero__orb');
window.addEventListener('mousemove', e => {
  const cx = e.clientX / window.innerWidth - 0.5;
  const cy = e.clientY / window.innerHeight - 0.5;
  orbs.forEach((orb, i) => {
    const depth = (i + 1) * 15;
    orb.style.transform = `translate(${cx * depth}px, ${cy * depth}px)`;
  });
});

console.log('◈ Tesoro Regional – Bienvenido al tesoro de Ñuble');
