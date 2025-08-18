class MongoDBConfig {
  // ⚠️ MONGODB ATLAS SRV CONNECTIONS NOT SUPPORTED!
  // 
  // The mongo_dart package doesn't support MongoDB Atlas SRV connections (mongodb+srv://)
  // 
  // ✅ WORKING ALTERNATIVES:
  // 1. Use Firebase Storage (recommended for Flutter apps)
  // 2. Use Cloudinary for image storage (already configured in your app)
  // 3. Use a standard MongoDB server with mongodb:// connection string
  // 4. Use local MongoDB: 'mongodb://localhost:27017'
  //
  // 🔐 Security Note: 
  // - Never commit your actual connection string to version control
  // - Consider using environment variables in production
  
  // For now, this will show as disconnected and use placeholder images
  static const String connectionString = 'mongodb+srv://HomeWebApp:NewAppHome12345@cluster0.9zmbmnc.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
  
  // Database and collection configuration
  static const String databaseName = 'rent_a_home';
  static const String collectionName = 'property_images';
  
  // Connection settings
  static const int connectionTimeout = 30000; // 30 seconds
  static const int queryTimeout = 15000; // 15 seconds
  
  /// Validate if the connection string is properly configured
  static bool isConfigured() {
    return connectionString != 'YOUR_MONGODB_CONNECTION_STRING_HERE' && 
           connectionString.isNotEmpty &&
           connectionString.startsWith('mongodb');
  }
  
  /// Get helpful configuration messages
  static String getConfigurationHelp() {
    return '''
❌ MongoDB Atlas SRV connections are not supported by mongo_dart package!

🔄 RECOMMENDED ALTERNATIVES:

1. 🔥 Firebase Storage (RECOMMENDED):
   - Already configured in your Flutter app
   - Perfect for image storage
   - Automatic CDN and optimization
   - Easy integration with Firebase Auth

2. ☁️ Cloudinary (ALREADY AVAILABLE):
   - Your app already has cloudinary_public package
   - Excellent image optimization and transformations
   - Global CDN delivery

3. 🗄️ Use standard MongoDB server:
   - Install MongoDB locally: mongodb://localhost:27017
   - Use MongoDB Cloud with standard connection string

For now, the app will use placeholder images until you choose an alternative.
''';
  }
}
