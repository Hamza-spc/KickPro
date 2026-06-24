import { Component } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';

@Component({
  selector: 'app-features',
  standalone: true,
  imports: [ScrollRevealDirective],
  templateUrl: './features.component.html',
  styleUrl: './features.component.css',
  animations: [
    trigger('reveal', [
      transition('hidden => visible', [
        style({ opacity: 0, transform: 'translateY(16px)' }),
        animate('650ms 0ms ease-out', style({ opacity: 1, transform: 'translateY(0px)' })),
      ]),
    ]),
  ],
})
export class FeaturesComponent {
  readonly features = [
    {
      icon: '🏟️',
      title: 'Book & Join Matches',
      desc: 'Find and book football venues near you or join matches organized by other players in your city.',
    },
    {
      icon: '🤖',
      title: 'AI Scout Assistant',
      desc: "Scouts search players in natural language: 'Find a left-footed striker under 20 in Casablanca' — AI does the rest.",
    },
    {
      icon: '🧠',
      title: 'AI Personal Coach',
      desc: 'Get a personalized football nutrition plan and drill recommendations based on your weak skills — powered by Gemini AI.',
    },
    {
      icon: '🎯',
      title: 'Drill Progression System',
      desc: 'Complete structured skill challenges at Beginner, Intermediate and Advanced levels. Earn badges that boost your profile visibility.',
    },
    {
      icon: '📊',
      title: 'Credibility Score',
      desc: 'A verified composite score based on drill results, match ratings, video ratings and certifications. Not self-declared — proven.',
    },
    {
      icon: '🎓',
      title: 'Football Certifications',
      desc: 'Complete micro-courses on tactics, discipline and positioning. Earn certificates that appear on your scout-facing profile.',
    },
  ] as const;
}
