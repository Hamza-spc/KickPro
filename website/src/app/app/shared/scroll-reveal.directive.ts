import { AfterViewInit, Directive, ElementRef, OnDestroy, inject, signal } from '@angular/core';

@Directive({
  selector: '[appScrollReveal]',
  standalone: true,
  exportAs: 'scrollReveal',
})
export class ScrollRevealDirective implements AfterViewInit, OnDestroy {
  private readonly el = inject<ElementRef<HTMLElement>>(ElementRef);
  private observer: IntersectionObserver | null = null;

  readonly visible = signal(false);

  ngAfterViewInit(): void {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          this.visible.set(true);
          this.observer?.disconnect();
          this.observer = null;
        }
      },
      { threshold: 0.15, rootMargin: '0px 0px -10% 0px' },
    );
    this.observer.observe(this.el.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
    this.observer = null;
  }
}
