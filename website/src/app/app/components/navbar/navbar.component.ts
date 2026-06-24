import { Component, HostListener, inject, signal } from '@angular/core';
import { SmoothScrollService } from '../../shared/smooth-scroll.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent {
  private readonly scroll = inject(SmoothScrollService);
  readonly isScrolled = signal(false);

  @HostListener('window:scroll')
  onScroll(): void {
    this.isScrolled.set(window.scrollY > 8);
  }

  goTo(id: string): void {
    this.scroll.scrollToId(id);
  }
}
