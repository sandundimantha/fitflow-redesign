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
        this.logger.warn(`Firebase Admin SDK init failed: ${err.message}.`);
      }
    }
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const headers = request.headers || {};
    const authHeader = (headers['authorization'] as string) || '';
    const devUserIdHeader = headers['x-dev-user-id'] as string | undefined;

    const devBypassRaw = this.configService.get<any>('DEV_AUTH_BYPASS_ENABLED', false);
    const devBypassEnabled = devBypassRaw === true || devBypassRaw === 'true';

    // 1. Check Dev Auth Bypass (Opt-in only: requires devBypassEnabled AND an explicit dev signal)
    // Never trigger on missing authHeader! An explicit dev signal is required.
    const hasExplicitDevSignal =
      (typeof devUserIdHeader === 'string' && devUserIdHeader.trim().length > 0) ||
      (typeof authHeader === 'string' && authHeader.includes('dev-token'));

    if (devBypassEnabled && hasExplicitDevSignal) {
      const userId =
        (devUserIdHeader && devUserIdHeader.trim()) ||
        this.configService.get<string>('DEV_USER_ID', 'usr_demo_777');

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

    // 2. Validate Authorization header format - reject any request without a Bearer token
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }

    const token = authHeader.split('Bearer ')[1]?.trim();
    if (!token) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }

    // 3. Fail closed if Firebase is not properly initialized
    if (!this.firebaseInitialized) {
      throw new UnauthorizedException('Authentication is not configured correctly');
    }

    // 4. Verify Firebase JWT
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
            displayName:
              decodedToken.name ||
              decodedToken.email?.split('@')[0] ||
              'FitFlow Athlete',
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
      throw new UnauthorizedException(
        'Invalid or expired Firebase authentication token',
      );
    }
  }
}
