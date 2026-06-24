import { Component } from '@angular/core';
import { StoreButtonsComponent } from '../store-buttons/store-buttons.component';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [StoreButtonsComponent],
  templateUrl: './footer.component.html',
  styleUrl: './footer.component.css'
})
export class FooterComponent {

}
