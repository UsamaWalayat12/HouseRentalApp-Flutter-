import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/property_bloc.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white, // High contrast white text on dark background
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.propertyTypes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: selectedCategory == null 
                            ? Colors.white 
                            : const Color(0xFF37474F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = null;
                      });
                      // Use SearchProperties with null propertyType to maintain consistency
                      context.read<PropertyBloc>().add(
                        SearchProperties(propertyType: null),
                      );
                    },
                    backgroundColor: Colors.white.withOpacity(0.9),
                    selectedColor: const Color(0xFF00C853),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: selectedCategory == null 
                          ? const Color(0xFF00C853) 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                );
              }
              
              final category = AppConstants.propertyTypes[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: selectedCategory == category 
                          ? Colors.white 
                          : const Color(0xFF37474F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = selected ? category : null;
                    });
                    context.read<PropertyBloc>().add(
                      SearchProperties(propertyType: selectedCategory),
                    );
                  },
                  backgroundColor: Colors.white.withOpacity(0.9),
                  selectedColor: const Color(0xFF00C853),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: selectedCategory == category 
                        ? const Color(0xFF00C853) 
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

