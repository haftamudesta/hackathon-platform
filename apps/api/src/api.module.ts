import { Module } from '@nestjs/common';
import { ApiController } from './api.controller';
import { ApiService } from './api.service';
import { UsersService } from './modules/users/users.service';

@Module({
  imports: [],
  controllers: [ApiController],
  providers: [ApiService, UsersService],
})
export class ApiModule {}
