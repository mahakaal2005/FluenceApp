# Agent Development Rules for Look Gig Flutter App

## Core Principles

### 1. ALWAYS Use MCP Servers

#### Figma MCP Server (MANDATORY when Figma links provided)
- **ALWAYS** use `mcp_Framelink_Figma_MCP_get_figma_data` to get design specifications
- **ALWAYS** use `mcp_Framelink_Figma_MCP_download_figma_images` to download images as PNG
- **PNG Scale**: Always use `pngScale: 2` for high-quality images
- **Never** manually create images or icons - always get from Figma

#### Sequential Thinking MCP Server (MANDATORY for complex tasks)
- **ALWAYS** use `mcp_sequential_thinking_mcp_sequentialthinking` before starting any task
- Break down complex problems into thought steps
- Analyze requirements, plan approach, identify potential issues
- Use for: UI implementation, backend integration, debugging, refactoring

### 2. Work in Chunks - NEVER Do Everything at Once

#### Task Breakdown Process
1. **Create mental task list** (not a separate document)
2. **Execute tasks sequentially** - one at a time
3. **Verify each step** before moving to next
4. **Never combine multiple major changes** in one operation

#### Example Workflow for New Screen
```
Task 1: Get Figma design data
Task 2: Download required images (PNG)
Task 3: Create screen file with basic structure
Task 4: Implement UI matching Figma specs
Task 5: Add route definition
Task 6: Test navigation
Task 7: Document any backend changes
```

#### File Editing Rules
- **NEVER** try to replace entire large files at once
- **Edit in steps**: Read → Identify section → Replace specific section → Verify
- **Use strReplace** for targeted changes, not whole file rewrites
- **If file is large**: Edit 50-100 lines at a time maximum

### 3. Figma to Flutter Implementation

#### Step-by-Step Process
1. **Extract Figma node-id** from URL (e.g., `node-id=35-19`)
2. **Get design data** using Figma MCP server
3. **Analyze layout**: dimensions, colors, fonts, spacing, images
4. **Download images** as PNG (identify all IMAGE-SVG, IMAGE, RECTANGLE with imageRef)
5. **Create UI** matching exact specifications:
   - Colors: Use exact hex values from Figma
   - Fonts: Match fontFamily, fontSize, fontWeight, lineHeight
   - Spacing: Use exact locationRelativeToParent values
   - Dimensions: Match width and height from Figma

#### Color Management
- Add new colors to `lib/utils/app_colors.dart`
- Use descriptive names (e.g., `lookGigPurple`, `lookGigLightGray`)
- Never hardcode colors in widgets - always use AppColors constants

#### Image Handling
- Save to `assets/images/` directory
- Use descriptive filenames (e.g., `main_illustration.png`, `google_icon.png`)
- Always provide errorBuilder for graceful fallback
- Use exact dimensions from Figma

### 4. Backend Preservation (CRITICAL)

#### NEVER Modify These Without Documentation
- `lib/services/auth_services.dart` - Authentication logic
- `lib/services/` - Any service files
- Firebase configuration
- Existing API calls
- Database queries
- State management logic

#### When Backend Changes Are Required
1. **Document FIRST** in `atul_docs/backend_changes.md`
2. **Explain WHY** the change is needed
3. **Show BEFORE and AFTER** code
4. **List affected files**
5. **Note any breaking changes**
6. **Then and only then** make the change

#### Safe Backend Practices
- Preserve all existing methods
- Keep all error handling intact
- Maintain all validation logic
- Don't change method signatures
- Don't remove any functionality
- Add new methods instead of modifying existing ones

### 5. UI-Only Changes (Preferred Approach)

#### What You CAN Change Freely
- Widget layouts and structure
- Colors, fonts, spacing
- Animations and transitions
- UI state (loading, error states)
- Form field styling
- Button appearances
- Navigation UI

#### What Requires Caution
- Form validation logic (preserve existing)
- Navigation routes (add, don't break existing)
- Controller initialization (keep existing)
- State management (preserve patterns)

### 6. Documentation Requirements

#### Backend Changes Documentation
- **File**: `atul_docs/backend_changes.md`
- **Format**:
  ```markdown
  ## [Date] - [Feature/Screen Name]
  
  ### Changes Made
  - File: path/to/file.dart
  - Change: Description of what changed
  - Reason: Why this change was necessary
  
  ### Code Changes
  #### Before
  ```dart
  // old code
  ```
  
  #### After
  ```dart
  // new code
  ```
  
  ### Impact
  - Affected screens: List
  - Breaking changes: Yes/No
  - Testing required: Description
  ```

#### NO Separate Documentation Files
- Don't create multiple documentation files
- Update single `backend_changes.md` file
- Append new changes to existing file
- Keep chronological order

### 7. Development Workflow Reference

#### Screens Implemented So Far

**1. Logo Screen (Splash)**
- Figma: node-id=35-60
- File: `lib/screens/initial/splash_screen.dart`
- Images: `look_gig_logo.png`
- Colors: `lookGigPurple` (#130160)
- Backend: Preserved Firebase auth check, navigation logic

**2. Onboarding Screen**
- Figma: node-id=35-68
- File: `lib/screens/initial/onboarding_screen.dart`
- Images: `main_illustration.png`, `bottom_icon.png`
- Colors: `lookGigLightGray` (#F9F9F9), `lookGigDescriptionText` (#524B6B)
- Backend: Preserved navigation to login

**3. Login Screen**
- Figma: node-id=35-19
- File: `lib/screens/login_signup/login_screen.dart`
- Images: `google_icon.png`
- Backend: Preserved ALL authentication logic, form validation, error handling, role-based navigation

**4. Signup Screen**
- File: `lib/screens/login_signup/signup_screen.dart`
- Backend: Preserved Firebase registration, role selection, validation

**5. Forgot Password Screen**
- Figma: node-id=35-171
- File: `lib/screens/login_signup/forgot_password_screen.dart`
- Images: `forgot_password_icon.png`
- Backend: Frontend only - backend integration pending

### 8. Common Patterns and Best Practices

#### Flutter Widget Structure
```dart
// Always use this structure for new screens
class ScreenName extends StatefulWidget {
  const ScreenName({super.key});
  
  @override
  State<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: // Your UI
        ),
      ),
    );
  }
}
```

#### Responsive Layout Pattern
```dart
Center(
  child: Container(
    constraints: const BoxConstraints(maxWidth: 375),
    padding: const EdgeInsets.symmetric(horizontal: 29),
    child: Column(
      children: [
        // Your widgets
      ],
    ),
  ),
)
```

#### Form Field Pattern (Matching Figma)
```dart
SizedBox(
  width: 317, // From Figma dimensions
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.lookGigPurple,
          fontFamily: 'DM Sans',
          height: 1.302,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF99ABC6).withOpacity(0.18),
              blurRadius: 62,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          // Field configuration
        ),
      ),
    ],
  ),
)
```

#### Button Pattern (Matching Figma)
```dart
Container(
  width: 266, // From Figma
  height: 50,
  decoration: BoxDecoration(
    color: AppColors.lookGigPurple,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF99ABC6).withOpacity(0.18),
        blurRadius: 62,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: _isLoading ? null : _handleAction,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lookGigPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      elevation: 0,
      padding: EdgeInsets.zero,
    ),
    child: _isLoading
        ? const CircularProgressIndicator(color: AppColors.white)
        : const Text(
            'BUTTON TEXT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              fontFamily: 'DM Sans',
              letterSpacing: 0.84,
              height: 1.302,
            ),
          ),
  ),
)
```

### 9. Error Handling and Debugging

#### When Things Go Wrong
1. **Read error message carefully**
2. **Use Sequential Thinking** to analyze the problem
3. **Check recent changes** - what was modified?
4. **Verify file paths** and imports
5. **Check for typos** in variable names
6. **Test incrementally** - don't make multiple changes at once

#### Common Issues and Solutions
- **LateInitializationError**: Initialize variables in initState()
- **Duplicate declarations**: Check for multiple variable definitions
- **Import errors**: Verify file paths and package names
- **Build errors**: Run `flutter pub get` after adding dependencies
- **Image not found**: Check assets are listed in pubspec.yaml

### 10. Quality Checklist

Before considering a task complete:
- [ ] UI matches Figma design pixel-perfectly
- [ ] All images downloaded and displaying correctly
- [ ] Colors match Figma specifications
- [ ] Fonts and text styles match Figma
- [ ] Spacing and dimensions match Figma
- [ ] Backend logic preserved and working
- [ ] Navigation working correctly
- [ ] Form validation working (if applicable)
- [ ] Error states handled gracefully
- [ ] Loading states implemented
- [ ] No console errors or warnings
- [ ] Backend changes documented (if any)

## Summary

**ALWAYS**:
- Use Figma MCP server for designs
- Use Sequential Thinking for complex tasks
- Work in chunks, step by step
- Download images as PNG
- Preserve backend logic
- Document backend changes

**NEVER**:
- Do everything at once
- Modify backend without documentation
- Hardcode colors or values
- Skip error handling
- Break existing functionality
- Create multiple documentation files

**REMEMBER**: You are a senior developer. Think carefully, plan thoroughly, execute methodically, and document properly.
                                                 