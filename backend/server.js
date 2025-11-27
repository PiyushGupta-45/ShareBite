import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';

// Load environment variables FIRST before importing any modules that use them
dotenv.config();

// Now import modules that depend on environment variables
import connectDB from './config/database.js';
import authRoutes from './routes/authRoutes.js';
import ngoRoutes from './routes/ngoRoutes.js';

// Validate required environment variables
const requiredEnvVars = ['MONGODB_URI', 'JWT_SECRET', 'GOOGLE_CLIENT_ID'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0) {
  console.error('❌ Missing required environment variables:');
  missingEnvVars.forEach(varName => {
    console.error(`   - ${varName}`);
  });
  console.error('\nPlease check your backend/.env file and ensure all required variables are set.');
  process.exit(1);
}

// Connect to database
connectDB();

const app = express();

// CORS Configuration - Allow all origins in development for Flutter apps
const allowedOrigins = process.env.FRONTEND_URL 
  ? [process.env.FRONTEND_URL]
  : ['*']; // Allow all in development

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin || allowedOrigins.includes('*')) {
      callback(null, true);
    } else if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all in development - change for production
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`\n📥 ${new Date().toISOString()} - ${req.method} ${req.path}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log(`   Body: ${JSON.stringify(req.body).substring(0, 100)}...`);
  }
  next();
});

// Response logging middleware
app.use((req, res, next) => {
  const originalSend = res.send;
  res.send = function (data) {
    console.log(`📤 ${req.method} ${req.path} - Status: ${res.statusCode}`);
    return originalSend.call(this, data);
  };
  next();
});

// Log environment status
console.log('✅ Environment variables loaded successfully');
console.log(`📡 CORS: Allowing all origins (development mode)`);
console.log(`🔑 Google Client ID: ${process.env.GOOGLE_CLIENT_ID ? '✅ Set' : '❌ Missing'}`);

// Routes
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Food Donation App API is running',
    version: '1.0.0',
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is healthy',
    timestamp: new Date().toISOString(),
  });
});

// Connectivity test endpoint for mobile apps
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'Backend is reachable!',
    timestamp: new Date().toISOString(),
    clientIP: req.ip || req.connection.remoteAddress,
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/ngos', ngoRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0'; // Listen on all network interfaces

app.listen(PORT, HOST, () => {
  console.log(`✅ Server running in ${process.env.NODE_ENV || 'development'} mode`);
  console.log(`📡 Listening on http://${HOST === '0.0.0.0' ? 'localhost' : HOST}:${PORT}`);
  console.log(`🌐 Accessible from network: http://YOUR_IP:${PORT}`);
  console.log(`📱 Android Emulator should use: http://10.0.2.2:${PORT}/api`);
});

