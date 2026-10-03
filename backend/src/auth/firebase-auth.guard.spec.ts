import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

const mockVerifyIdToken = jest.fn();

jest.mock('firebase-admin', () => ({
  apps: [],
  initializeApp: jest.fn(),
  credential: {
    cert: jest.fn(),
  },
  auth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
}));

describe('FirebaseAuthGuard', () => {
  let prismaMock: any;

  beforeEach(() => {
    jest.clearAllMocks();
    prismaMock = {
      user: {
        findFirst: jest.fn().mockResolvedValue(null),
        findUnique: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockImplementation((args) =>
          Promise.resolve({ id: 'usr_created', ...args.data }),
        ),
      },
    };
  });

  function createMockContext(headers: Record<string, string> = {}): {
    context: ExecutionContext;
    request: any;
  } {
    const request: any = { headers };
    const context = {
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
    return { context, request };
  }

  function createGuard(configValues: Record<string, any> = {}): FirebaseAuthGuard {
    const configService = {
      get: jest.fn((key: string, defaultValue?: any) => {
        if (key in configValues) {
          return configValues[key];
        }
        return defaultValue;
      }),
    } as unknown as ConfigService;

    return new FirebaseAuthGuard(configService, prismaMock as PrismaService);
  }

  it('1. Request with no Authorization header and DEV_AUTH_BYPASS_ENABLED=false -> rejected with 401', async () => {
    const guard = createGuard({
      DEV_AUTH_BYPASS_ENABLED: false,
    });
    const { context } = createMockContext({});

    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(context)).rejects.toThrow(
      'Missing or invalid Authorization header',
    );
  });

  it('2. Request with no Authorization header and DEV_AUTH_BYPASS_ENABLED=true and no x-dev-user-id header -> rejected with 401 (bypass requires the explicit header, not just the flag)', async () => {
    const guard = createGuard({
      DEV_AUTH_BYPASS_ENABLED: true,
    });
    const { context } = createMockContext({});

    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(context)).rejects.toThrow(
      'Missing or invalid Authorization header',
    );
  });

  it('3. Request with a valid x-dev-user-id header and DEV_AUTH_BYPASS_ENABLED=true -> authenticated as that dev user', async () => {
    const guard = createGuard({
      DEV_AUTH_BYPASS_ENABLED: true,
    });
    const { context, request } = createMockContext({
      'x-dev-user-id': 'usr_dev_tester_123',
    });

    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    expect(request.user).toBeDefined();
    expect(request.user.id).toBe('usr_dev_tester_123');
    expect(request.user.firebaseUid).toBe('firebase_usr_dev_tester_123');
  });

  it('4. Request when Firebase Admin SDK fails to initialize and bypass is off -> rejected with 401, not silently authenticated', async () => {
    // Config lacks valid Firebase credentials, so firebaseInitialized remains false
    const guard = createGuard({
      DEV_AUTH_BYPASS_ENABLED: false,
      FIREBASE_PROJECT_ID: '',
      FIREBASE_CLIENT_EMAIL: '',
      FIREBASE_PRIVATE_KEY: '',
    });
    const { context } = createMockContext({
      authorization: 'Bearer sample-token-xyz',
    });

    await expect(guard.canActivate(context)).rejects.toThrow(
      UnauthorizedException,
    );
    await expect(guard.canActivate(context)).rejects.toThrow(
      'Authentication is not configured correctly',
    );
  });

  it('5. Request with a valid Firebase JWT -> authenticated as the correct user', async () => {
    const guard = createGuard({
      DEV_AUTH_BYPASS_ENABLED: false,
      FIREBASE_PROJECT_ID: 'fitflow-proj',
      FIREBASE_CLIENT_EMAIL: 'admin@fitflow-proj.iam.gserviceaccount.com',
      FIREBASE_PRIVATE_KEY: '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC6...\n-----END PRIVATE KEY-----\n',
    });

    mockVerifyIdToken.mockResolvedValueOnce({
      uid: 'firebase_user_789',
      email: 'athlete@fitflow.app',
      name: 'Sarah Connor',
    });

    prismaMock.user.findUnique.mockResolvedValueOnce({
      id: 'usr_real_789',
      firebaseUid: 'firebase_user_789',
      email: 'athlete@fitflow.app',
      displayName: 'Sarah Connor',
    });

    const { context, request } = createMockContext({
      authorization: 'Bearer valid-firebase-jwt-token',
    });

    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    expect(request.user).toBeDefined();
    expect(request.user.id).toBe('usr_real_789');
    expect(request.user.firebaseUid).toBe('firebase_user_789');
    expect(request.user.displayName).toBe('Sarah Connor');
  });
});
