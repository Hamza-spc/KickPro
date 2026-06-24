import { Component } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';

@Component({
  selector: 'app-how-it-works',
  standalone: true,
  imports: [ScrollRevealDirective],
  templateUrl: './how-it-works.component.html',
  styleUrl: './how-it-works.component.css',
  animations: [
    trigger('reveal', [
      transition('hidden => visible', [
        style({ opacity: 0, transform: 'translateY(16px)' }),
        animate('650ms 0ms ease-out', style({ opacity: 1, transform: 'translateY(0px)' })),
      ]),
    ]),
  ],
})
export class HowItWorksComponent {

}
