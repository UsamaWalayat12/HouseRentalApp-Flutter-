import 'package:flutter/material.dart';

class Model3D {
  final String name;
  final String path;
  final String category;
  final String description;

  const Model3D({
    required this.name,
    required this.path,
    required this.category,
    required this.description,
  });
}

class ModelService {
  static const List<Model3D> preloadedModels = [
    Model3D(
      name: 'Modern House',
      path: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      category: 'house',
      description: 'A modern house with detailed interior and exterior',
    ),
    Model3D(
      name: 'Luxury Apartment',
      path: 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
      category: 'apartment',
      description: 'Luxurious apartment with modern furnishings',
    ),
    Model3D(
      name: 'Studio Room',
      path: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      category: 'room',
      description: 'Cozy studio room with essential amenities',
    ),
    Model3D(
      name: 'Modern Kitchen',
      path: 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
      category: 'room',
      description: 'Contemporary kitchen with modern appliances',
    ),
    Model3D(
      name: 'Master Bedroom',
      path: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      category: 'room',
      description: 'Spacious master bedroom with en-suite',
    ),
  ];

  static Future<String?> uploadModel(String localPath) async {
    // TODO: Implement Firebase Storage upload
    return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
  }

  static List<Model3D> getModelsByCategory(String category) {
    return preloadedModels.where((model) => model.category == category).toList();
  }

  static List<String> get categories {
    return ['house', 'apartment', 'room'];
  }
} 