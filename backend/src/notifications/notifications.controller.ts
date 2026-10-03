import { Controller, Get, Patch, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { FirebaseAuthGuard } from '../auth/firebase-auth.guard';
import { CurrentUser, AuthUser } from '../auth/current-user.decorator';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({
    summary: 'List recent notifications visually distinguished by type (expert_reply, alert, confirmation)',
  })
  async getNotifications(@CurrentUser() user: AuthUser) {
    return await this.notificationsService.findAll(user.id);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark a notification as read' })
  async markAsRead(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return await this.notificationsService.markAsRead(id, user.id);
  }
}
