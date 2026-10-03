import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(FirebaseAuthGuard.name);
  private firebaseInitialized = false;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

    if (projectId && clientEmail && privateKey && privateKey.length > 20) {
      try {
        if (!admin.apps.length) {
          admin.initializeApp({
            credential: admin.credential.cert({
              projectId,
              clientEmail,
              privateKey: privateKey.replace(/\\n/g, '\n'),
            }),
          });
        }
        this.firebaseInitialized = true;
        this.logger.log('Firebase Admin SDK initialized successfully');
      } catch (err) {
        this.logger.warn(`Firebase Admin SDK init failed: ${err.message}. Running in fallback dev mode.`);
      }
    }
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'] || '';
    const devUserIdHeader = request.headers['x-dev-user-id'];
    const devBypassEnabled = this.configService.get<boolean>('DEV_AUTH_BYPASS_ENABLED', true);

    // 1. Check Dev Auth Bypass
    if (devBypassEnabled && (devUserIdHeader || authHeader.includes('dev-token') || !authHeader)) {
      const userId = (devUserIdHeader as string) || this.configService.get<string>('DEV_USER_ID', 'usr_demo_777');
      
      // Attempt to look up user or assign mock user
      let user = null;
      try {
        user = await this.prisma.user.findFirst({
          where: { OR: [{ id: userId }, { firebaseUid: userId }] },
        });
      } catch (e) {}

      request.user = {
        id: user ? user.id : userId,
        firebaseUid: user ? user.firebaseUid : `firebase_${userId}`,
        email: user?.email || 'demo@fitflow.app',
        displayName: user?.displayName || 'Alex Morgan',
      };
      return true;
    }

    // 2. Validate Firebase JWT
    if (!authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }

    const token = authHeader.split('Bearer ')[1];

    if (!this.firebaseInitialized) {
      // If live Firebase credentials are not yet populated, support dev token
      request.user = {
        id: 'usr_demo_777',
        firebaseUid: 'firebase_usr_demo_777',
        email: 'demo@fitflow.app',
        displayName: 'Alex Morgan',
      };
      return true;
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      let user = await this.prisma.user.findUnique({
        where: { firebaseUid: decodedToken.uid },
      });

      if (!user) {
        // Auto-provision user record on first token presentation
        user = await this.prisma.user.create({
          data: {
            firebaseUid: decodedToken.uid,
            email: decodedToken.email || null,
            phone: decodedToken.phone_number || null,
            displayName: decodedToken.name || decodedToken.email?.split('@')[0] || 'FitFlow Athlete',
            avatarUrl: decodedToken.picture || null,
          },
        });
      }

      request.user = {
        id: user.id,
        firebaseUid: user.firebaseUid,
        email: user.email,
        displayName: user.displayName,
      };
      return true;
    } catch (err) {
      this.logger.error(`Token verification failed: ${err.message}`);
      throw new UnauthorizedException('Invalid or expired Firebase authentication token');
    }
  }
}
