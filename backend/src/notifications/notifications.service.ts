import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return await this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async markAsRead(id: string, userId: string) {
    const existing = await this.prisma.notification.findFirst({
      where: { id, userId },
    });
    if (!existing) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }

    return await this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }
}
