import { Component } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { StoreButtonsComponent } from '../../components/store-buttons/store-buttons.component';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';

@Component({
  selector: 'app-hero-about',
  standalone: true,
  imports: [StoreButtonsComponent, ScrollRevealDirective],
  templateUrl: './hero-about.component.html',
  styleUrl: './hero-about.component.css',
  animations: [
    trigger('reveal', [
      transition('hidden => visible', [
        style({ opacity: 0, transform: 'translateY(16px)' }),
        animate('650ms 0ms ease-out', style({ opacity: 1, transform: 'translateY(0px)' })),
      ]),
    ]),
  ],
})
export class HeroAboutComponent {
  readonly phoneSrc = 'assets/phone_mockup.png';
}
