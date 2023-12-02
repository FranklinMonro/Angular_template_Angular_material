/* eslint-disable import/prefer-default-export */
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { MatSidenavModule } from '@angular/material/sidenav';

import { HomeRoutingModule } from './home-routing.module';
import { HomeComponent } from './home.component';
import { HeaderComponent } from './layout/header/header.component';
import { SideNavComponent } from './layout/side-nav/side-nav.component';
import { MainContentComponent } from './layout/main-content/main-content.component';
import { ComponentsModule } from './components/components.module';

@NgModule({
  declarations: [
    HomeComponent,
    HeaderComponent,
    SideNavComponent,
    MainContentComponent,
  ],
  imports: [
    CommonModule,
    HomeRoutingModule,
    ComponentsModule,
  ],
  exports: [
    MatSidenavModule,
  ],
})
export class HomeModule { }
