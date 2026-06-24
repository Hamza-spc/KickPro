import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-store-buttons',
  standalone: true,
  imports: [],
  templateUrl: './store-buttons.component.html',
  styleUrl: './store-buttons.component.css'
})
export class StoreButtonsComponent {
  @Input() compact = false;
}
