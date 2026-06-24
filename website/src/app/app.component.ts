import { Component } from '@angular/core';
import { NavbarComponent } from './app/components/navbar/navbar.component';
import { FooterComponent } from './app/components/footer/footer.component';
import { HeroAboutComponent } from './app/sections/hero-about/hero-about.component';
import { HowItWorksComponent } from './app/sections/how-it-works/how-it-works.component';
import { FeaturesComponent } from './app/sections/features/features.component';
import { PricingComponent } from './app/sections/pricing/pricing.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    NavbarComponent,
    HeroAboutComponent,
    HowItWorksComponent,
    FeaturesComponent,
    PricingComponent,
    FooterComponent,
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  readonly year = new Date().getFullYear();
}
