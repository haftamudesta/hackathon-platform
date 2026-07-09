import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService, Role } from '@app/database';
import { UpdateUserDto } from './dto/update-user.dto';

const PUBLIC_USER_SELECT = {
  id: true,
  email: true,
  name: true,
  avatarUrl: true,
  bio: true,
  skills: true,
  role: true,
  createdAt: true,
};

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll(role?: Role) {
    return this.prisma.user.findMany({
      where: role ? { role } : undefined,
      select: PUBLIC_USER_SELECT,
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id }, select: PUBLIC_USER_SELECT });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async update(id: string, dto: UpdateUserDto) {
    await this.findById(id);
    return this.prisma.user.update({
      where: { id },
      data: dto,
      select: PUBLIC_USER_SELECT,
    });
  }

  async setRole(id: string, role: Role) {
    await this.findById(id);
    return this.prisma.user.update({ where: { id }, data: { role }, select: PUBLIC_USER_SELECT });
  }

  async deactivate(id: string) {
    await this.findById(id);
    return this.prisma.user.update({ where: { id }, data: { isActive: false }, select: PUBLIC_USER_SELECT });
  }
}