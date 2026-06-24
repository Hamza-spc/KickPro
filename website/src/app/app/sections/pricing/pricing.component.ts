import { Component } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';

@Component({
  selector: 'app-pricing',
  standalone: true,
  imports: [ScrollRevealDirective],
  templateUrl: './pricing.component.html',
  styleUrl: './pricing.component.css',
  animations: [
    trigger('reveal', [
      transition('hidden => visible', [
        style({ opacity: 0, transform: 'translateY(16px)' }),
        animate('650ms 0ms ease-out', style({ opacity: 1, transform: 'translateY(0px)' })),
      ]),
    ]),
  ],
})
export class PricingComponent {
  readonly playerFree = [
    'Create profile & upload videos',
    'Complete drills & earn badges',
    'Join & book matches',
    'Basic AI coach access',
    'Apply to trials',
  ];

  readonly playerPro = [
    'Higher quality video uploads on feed',
    'More direct messages to scouts & agents',
    'Access to exclusive trial announcements',
    'Priority visibility in scout search results',
  ];

  readonly venuesBenefits = [
    'Free listing with photos & description',
    'Manage availability & bookings',
    'Reach thousands of active players',
    'No subscription, no upfront cost',
  ];

  readonly agentsBenefits = [
    'Full access to verified player database',
    'AI-powered natural language player search',
    'Direct messaging with players',
    'Official verified agent badge',
    'Post exclusive trial announcements',
  ];
}
