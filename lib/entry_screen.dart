import 'package:flutter/material.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// import 'package:wellbeing_mobile_app/main.dart'; // Typically not needed here


// --- NEW IMPORTS FOR FIREBASE INTEGRATION ---
import 'package:wellbeing_mobile_app/models/wellbeing_entry.dart';
import 'package:wellbeing_mobile_app/services/firestore_service.dart';
import 'package:wellbeing_mobile_app/history_screen.dart'; // <--- NEW HISTORY SCREEN IMPORT


// --- SERVICE INSTANCE & GLOBAL STATE ---
final FirestoreService _firestoreService = FirestoreService();


// --- THEMATIC DATA MODELS FOR SURVEY OPTIONS ---


// 1. Mood Check (Horizontal Cards) - FINALIZED
const List<Map<String, dynamic>> moodOptions = [
  // NEW: Score 0 added as the default/unselected state
  {'value': 0, 'label': 'Awaiting Input', 'subtitle': 'Tap a pill below to begin your check-in.', 'color': AppColors.textSubtle, 'icon': '🤔'}, 
  // User-selectable options
  {'value': 1, 'label': 'Disaster Mode', 'subtitle': 'Rough day, but still standing.', 'color': Color(0xFFE57373), 'icon': '🚨'}, // Red
  {'value': 2, 'label': 'Low Battery', 'subtitle': 'Energy’s low; but still online.', 'color': Color(0xFFFFB74D), 'icon': '🔋'}, // Orange
  {'value': 3, 'label': 'Cruise Control', 'subtitle': 'Keeping pace, autopilot engaged.', 'color': Color(0xFFFFEB3B), 'icon': '🚗'}, // Yellow
  {'value': 4, 'label': 'Feeling Solid', 'subtitle': 'Focused and calm; just executing.', 'color': Color(0xFF64B5F6), 'icon': '👍'}, // Blue
  {'value': 5, 'label': 'Absolutely Stellar', 'subtitle': 'Running on pure momentum, everything’s clicking.', 'color': Color(0xFF81C784), 'icon': '✨'}, // Green
];


// 2. Sleep Log Labels (Custom Selector) - Scale 1-4
const List<Map<String, dynamic>> sleepOptions = [
{'value': 4, 'hours': '+8 Hours', 'status': 'Full Moon', 'detail': 'Dreams achieved, system restored. You’re basically invincible.', 'icon': '🌕'},
{'value': 3, 'hours': 'Around 8 Hours', 'status': 'Gibbous Moon', 'detail': 'Right in the sweet spot — efficient, balanced, unstoppable.', 'icon': '🌔'},
{'value': 2, 'hours': '4–6 Hours', 'status': 'Crescent Moon', 'detail': 'You’re awake, technically. Functionality may vary.', 'icon': '🌒'},
{'value': 1, 'hours': 'Under 4 Hours', 'status': 'New Moon', 'detail': 'Reality’s blurry, time isn’t real, and your bed misses you.', 'icon': '🌑'},
];


// 3. Move Report (Gauge Selector) - Scale 1-5
const List<Map<String, dynamic>> moveOptions = [
{'value': 1, 'label': '⏸️ System Standby', 'minutes': 'No movement', 'status': 'Energy conserved, maybe tomorrow.', 'color': Color(0xFFC9CCD3)},
{'value': 2, 'label': '🔋 Quick Battery Top-Up', 'minutes': '15-30 Minutes', 'status': 'Quick charge, mission complete.', 'color': Color(0xFFFFCC33)},
{'value': 3, 'label': '🟢 Mission Successful', 'minutes': '1 Hour', 'status': 'Steady grind, strong showing.', 'color': Color(0xFF69C07A)},
{'value': 4, 'label': '⚡ Full Power Burn', 'minutes': '2 Hours', 'status': 'Locked in, solid work.', 'color': Color(0xFF3399FF)},
{'value': 5, 'label': '🚀 Hyperdrive Activated!', 'minutes': '+2 Hours', 'status': 'Beast session, max effort.', 'color': Color(0xFFFF5555)},
];
// -----------------------------------------------


// In lib/entry_screen.dart
class DailyCheckinScreen extends StatefulWidget {
const DailyCheckinScreen({super.key});


@override
State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}
// ... rest of the file


class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
// State variables set to 0 (non-valid choice) to prevent initial highlighting
int _selectedMood = 0;
int _selectedSleep = 0;
int _selectedExercise = 0;
int _waterGlasses = 0;
final TextEditingController _notesController = TextEditingController();


// NEW: State for loading/saving process
bool _isSaving = false;


@override
void dispose() {
  _notesController.dispose();
  super.dispose();
}
 // Checks if the mandatory fields have been selected (Mood, Sleep, Exercise > 0)
bool _isFormValid() {
  return _selectedMood > 0 && _selectedSleep > 0 && _selectedExercise > 0;
}


// --- Firebase Save Logic (FIXED: Added mounted checks after await) ---
void _saveEntry() async {
  if (_isSaving) return; // Prevent double-tap


  if (!_isFormValid()) {
    // Line 119: use_build_context_synchronously (This one is OK, as no await preceded it)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛑 Please select your Mood, Sleep, and Movement before saving.'),
        backgroundColor: AppColors.textDark,
      ),
    );
    return;
  }


  setState(() {
    _isSaving = true;
  });


  try {
    // 1. Get the current authenticated user's ID
    final userId = _firestoreService.currentUserId;


    // 2. Check if the user already submitted today
    final alreadySubmitted = await _firestoreService.hasUserSubmittedToday(userId);
   
    // FIX 1: Add mounted check after the first await
    if (!mounted) return; // FIXES line 145 and 162 logic below if widget is disposed
   
    if (alreadySubmitted) {
        // Line 145: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ You have already submitted your check-in for today.'),
            backgroundColor: Color(0xFFFFB74D), // Orange for warning
          ),
        );
        setState(() { _isSaving = false; });
        return;
    }
  
    // 3. Create the WellbeingEntry object using the EXTERNAL model
    final entry = WellbeingEntry(
      moodScore: _selectedMood,
      sleepRating: _selectedSleep,
      exerciseValue: _selectedExercise,
      waterGlasses: _waterGlasses,
      notes: _notesController.text,
      timestamp: DateTime.now(),
      userId: userId,
    );


    // 4. Save the object using the Firestore service
    await _firestoreService.saveEntry(entry);
  
    // FIX 2: Add mounted check after the second await
    if (!mounted) return; // Catches context usage below
   
    // Success feedback
    // Line 162: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Check-in successfully logged!'),
        backgroundColor: Color(0xFF81C784), // Green
      ),
    );
    // Optional: Clear fields after successful save
    // setState(() {
    //   _selectedMood = 0; _selectedSleep = 0; _selectedExercise = 0; _waterGlasses = 0;
    //   _notesController.clear();
    // });


  } catch (e) {
    // Error feedback
    // Need to re-check mounted here in case the exception was thrown after a long wait
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error saving entry: Check console for details.'),
        backgroundColor: Color(0xFFE57373), // Red
      ),
    );
    debugPrint('Firestore Save Error: $e');
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}
// --- END OF _saveEntry METHOD ---


// --- WIDGET 1: Horizontal Mood Selector (Mood Check) ---
Widget _buildHorizontalMoodSelector({
  required String title,
  required String subtitle,
  required int selectedValue,
  required List<Map<String, dynamic>> options,
  required ValueChanged<int> onChanged,
}) {
  
  // *** SIMPLIFIED LOOKUP thanks to the new moodOptions[0] entry ***
  final Map<String, dynamic> selectedOption = options.cast<Map<String, dynamic>?>().firstWhere(
    (opt) => opt?['value'] == selectedValue,
    orElse: () => options.first, // Safely defaults to the 'Awaiting Input' (score 0)
  )!;
   
  final String statusLabel = selectedOption['label'] as String;
  final String statusSubtitle = selectedOption['subtitle'] as String;
  final String statusIcon = selectedOption['icon'] as String;
  final Color statusColor = selectedOption['color'] as Color;


  return Card(
    elevation: 0,
    color: AppColors.secondary,
    margin: const EdgeInsets.only(bottom: 20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text( // Made const (Title is static)
            'Mood Check: Quick scan — How’s the vibe today?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text( // Made const (Subtitle is static)
            'Select the option that best describes your current energy state.',
            style: TextStyle(fontSize: 14, color: AppColors.textSubtle),
          ),
          const SizedBox(height: 12),
        
          // ADDED: Status Display
          ListTile( // <-- MUST NOT BE CONST
            contentPadding: EdgeInsets.zero,
            leading: Text(
                statusIcon,
                style: TextStyle(fontSize: 32, color: statusColor),
              ),
            // FIX LINE 217: const removed here
            title: Text( 
              'Status: $statusLabel',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            // FIX LINE 222: const removed here
            subtitle: Text(
              statusSubtitle,
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(height: 12),


          // Horizontal Scrolling Area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // ALIGNMENT FIX RE-APPLIED: Forces content to align left
              mainAxisAlignment: MainAxisAlignment.start,
              // SKIPS the 0 option for the tapable pills
              children: options.where((option) => option['value']! > 0).map((option) {
                final isSelected = option['value'] == selectedValue;
              
                final Color selectedPillColor = option['color'] as Color;
              
                // Set the card color to the specific mood color regardless of selection state.
                final cardColor = selectedPillColor;
              
                // Text contrast logic
                final bool isLightColor = option['value'] >= 2 && option['value'] <= 4;
                final textColor = isLightColor ? AppColors.textDark : AppColors.background;
              
                // Border will only show the primary color when selected.
                // CORRECTED DEPRECATION: lib/entry_screen.dart:271 (was withOpacity)
                final borderColor = isSelected ? AppColors.primaryColor : cardColor.withAlpha((255 * 0.9).round());


                return Padding(
                  // FIX: This was causing an error if const was applied. Kept as const now that `TextStyles` are fixed.
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => onChanged(option['value'] as int),
                    child: Card(
                      elevation: isSelected ? 4 : 0,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        // Highlight the selected item with a thicker primary border
                        side: BorderSide(color: borderColor, width: isSelected ? 3 : 1),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        // Apply the color directly to the Container's decoration
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Only the Text label remains
                            Text(
                              option['label'] as String,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
 // --- WIDGET 2: Custom Thematic Sleep Selector (Fixed Options) ---
Widget _buildThematicSleepSelector() {
  final selectedOption = sleepOptions.cast<Map<String, dynamic>?>().firstWhere(
    (opt) => opt?['value'] == _selectedSleep,
    // Default option when nothing is selected
    orElse: () => {'hours': 'N/A', 'status': 'Awaiting Input', 'detail': 'Please tap an option below to log your sleep duration.', 'icon': ''},
  )!;
   final displayOptions = List.from(sleepOptions.reversed);


  return Card(
    elevation: 0,
    color: AppColors.secondary,
    margin: const EdgeInsets.only(bottom: 20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed unnecessary 'const' on TextStyle (lib/entry_screen.dart:341 in previous analysis)
          const Text(
            'Sleep Log: Your Night Power-Up',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
        
          // Current Selection Display (Dynamic Detail)
          ListTile(
            contentPadding: EdgeInsets.zero,
            // REVERTED to use EMOJI ICONS
            leading: _selectedSleep > 0
                ? Text(
                    selectedOption['icon'] as String,
                    style: const TextStyle(fontSize: 32),
                  )
                : const Icon(
                    Icons.bedtime, // Default icon when not selected
                    color: AppColors.textSubtle,
                    size: 32
                  ),
            title: Text(
              '${selectedOption['hours']} — ${selectedOption['status']}',
              style: TextStyle(fontWeight: FontWeight.bold, color: _selectedSleep > 0 ? AppColors.primaryColor : AppColors.textSubtle),
            ),
            subtitle: Text(
              selectedOption['detail'],
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(height: 12),


          // Custom Selector Track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: displayOptions.map((option) {
              final isSelected = option['value'] == _selectedSleep;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSleep = option['value'] as int),
                  child: Column(
                    children: [
                      // The clickable dot
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // CORRECTED DEPRECATION: lib/entry_screen.dart:389 (was withOpacity)
                          // Consistently active base color for all dots
                          color: AppColors.primaryColor.withAlpha((255 * 0.5).round()),
                          border: Border.all(
                            // Highlight selected dot with the accent color border
                            color: isSelected ? AppColors.accent : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    
                      // Hours Label
                      Text(
                        option['hours'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.textDark : AppColors.textSubtle,
                        ),
                      ),
                    
                      // Status Label (Moon Phase Name)
                      Text(
                        option['status'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppColors.primaryColor : AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


// --- WIDGET 3: Move Report Gauge Selector (Thematic Power Bar) ---
Widget _buildMoveGaugeSelector() {
  final int selectedValue = _selectedExercise;


  final selectedOption = moveOptions.cast<Map<String, dynamic>?>().firstWhere(
    (opt) => opt?['value'] == selectedValue && selectedValue > 0,
    orElse: () => {
      'label': '⏸️ System Standby',
      'minutes': 'No movement',
      'status': 'Energy conserved, maybe tomorrow.',
      'color': AppColors.textSubtle
    },
  )!;
   return Card(
    elevation: 0,
    color: AppColors.secondary,
    margin: const EdgeInsets.only(bottom: 20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed unnecessary 'const' keyword: lib/entry_screen.dart:460 (Already removed)
          const Text(
            'Movement Mission: Your Daily Activity Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          // NEW SUBTITLE/PROMPT (FIX APPLIED HERE)
          const Text(
            'Did you move your body yesterday? Log your minutes below.',
            style: TextStyle(fontSize: 14, color: AppColors.textSubtle), // Removed unnecessary const
          ),
          const SizedBox(height: 12),
        
          // Current Selection Display
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.bolt,
              color: selectedOption['color'] as Color,
              size: 32
            ),
            // Removed const here (Line 475) - Not strictly needed, but kept as Text is constant here
            title: Text(
              selectedOption['label'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            // FIX: Removed const from TextStyle to resolve invalid_constant (Line 482)
            subtitle: Text(
              '${selectedOption['minutes']} — ${selectedOption['status']}',
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(height: 12),


          // The Horizontal Gauge Control (Red Active Bar)
          Row(
            children: moveOptions.map((option) {
              final int value = option['value'] as int;
              // isActivated determines if the bar segment is filled (value <= selectedValue)
              final bool isActivated = value <= selectedValue && selectedValue > 0;
            
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedExercise = value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      children: [
                        // Top Label (Icon/Hours)
                        Text(
                          option['minutes'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActivated ? FontWeight.bold : FontWeight.normal,
                            color: isActivated ? AppColors.textDark : AppColors.textSubtle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // The Power Segment (Bar)
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            // CORRECTED DEPRECATION (1 of 2): lib/entry_screen.dart:524 (was withOpacity)
                            color: isActivated
                                ? option['color'].withAlpha((255 * 0.8).round())
                                // CORRECTED DEPRECATION (2 of 2): lib/entry_screen.dart:524 (was withOpacity)
                                : AppColors.textSubtle.withAlpha((255 * 0.2).round()),
                            borderRadius: BorderRadius.horizontal(
                              left: value == 1 ? const Radius.circular(8) : Radius.zero,
                              right: value == 5 ? const Radius.circular(8) : Radius.zero,
                            ),
                            // Border for current selection
                            border: value == selectedValue
                                ? Border.all(color: AppColors.primaryColor, width: 2)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Removed the Text widget, but keep a SizedBox for padding if needed
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}


// --- WIDGET 4: Water Counter with Dynamic Status and Liter Conversion (FIXED LIMIT) ---
Widget _buildCounterInput({
  required String title,
  required String unit,
  required int value,
  required ValueChanged<int> onChanged,
}) {
  // Hard limit based on our discussion (16 glasses = 4 liters)
  const int maxGlasses = 16;
   // --- Hydration Status Logic ---
  // Assuming 1 glass = 250ml (0.25L)
  final double liters = value * 0.25;
   String levelText;
  String statusMessage;
  String icon;
  Color statusColor;


  if (value == 0) {
    levelText = 'Zero Intake';
    statusMessage = '🏜️ Dry as the Sahara Desert. Find your first glass!';
    icon = '🚫';
    statusColor = const Color(0xFFE57373); // Red
  } else if (value >= 1 && value <= 3) {
    levelText = 'Low Priority';
    statusMessage = '💧 A small drip. Keep the system online.';
    icon = '📉';
    statusColor = const Color(0xFFFFB74D); // Orange
  } else if (value >= 4 && value <= 7) {
    levelText = 'Halfway Mark';
    statusMessage = '⛽ Tank is half-full! Cruising along nicely.';
    icon = '🟡';
    statusColor = const Color(0xFFFFEB3B); // Yellow
  } else if (value >= 8 && value <= 12) {
    levelText = 'Optimal Zone';
    statusMessage = '🌊 Peak Hydration! Your system is running perfectly.';
    icon = '✅';
    statusColor = const Color(0xFF81C784); // Green
  } else if (value >= 13 && value <= maxGlasses) {
    // Note: This range now includes 16, which is the hard limit
    levelText = 'High Performance';
    statusMessage = '🚀 Power Surge! Excellent job keeping up with activity.';
    icon = '🌟';
    statusColor = const Color(0xFF64B5F6); // Blue
  } else {
    // This section should technically not be reachable due to the button limit
    levelText = 'Max Capacity Reached';
    statusMessage = '🛑 **Limit Reached:** Max safe recommendation recorded.';
    icon = '🛑';
    statusColor = const Color(0xFFE57373); // Red
  }


  return Card(
    elevation: 0,
    color: AppColors.secondary,
    margin: const EdgeInsets.only(bottom: 20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX: Replaced invalid 'Title : ...' line with the correct Text widget using the 'title' argument
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          
          // --- NEW: Dynamic Status Display ---
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              icon,
              style: TextStyle(fontSize: 32, color: statusColor),
            ),
            // FIX: const was removed here (line 613/614 previously)
            title: Text( 
              'Level: $levelText',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            subtitle: Text(
              statusMessage,
              style: const TextStyle(color: AppColors.textSubtle),
            ),
          ),
          const SizedBox(height: 12),
        
          // --- Counter Row (FIXED LOGIC) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement button
              FloatingActionButton(
                heroTag: 'decrement${title.replaceAll(' ', '')}',
                mini: true,
                // CORRECTED DEPRECATION: lib/entry_screen.dart:648 (was withOpacity)
                onPressed: () => onChanged(value > 0 ? value - 1 : 0),
                backgroundColor: AppColors.primaryColor.withAlpha((255 * 0.8).round()),
                child: const Icon(Icons.remove, color: AppColors.background),
              ),
            
              // Value Display (Glasses + Liters)
              RichText(
                // FIX: Removed const from TextSpan style to resolve invalid_constant (Line 630)
                text: TextSpan(
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  children: [
                    TextSpan(text: '$value'),
                    TextSpan(text: ' $unit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textSubtle)),
                    TextSpan(text: ' (≈${liters.toStringAsFixed(1)}L)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textSubtle)),
                  ],
                ),
              ),
            
              // Increment button: LIMITED TO MAX 16
              FloatingActionButton(
                heroTag: 'increment${title.replaceAll(' ', '')}',
                mini: true,
                onPressed: () => onChanged(value < maxGlasses ? value + 1 : maxGlasses), // <-- HARD LIMIT APPLIED HERE
                // CORRECTED DEPRECATION: lib/entry_screen.dart:670 (was withOpacity)
                backgroundColor: value < maxGlasses ? AppColors.primaryColor : AppColors.textSubtle.withAlpha((255 * 0.5).round()), // Visual feedback
                child: const Icon(Icons.add, color: AppColors.background),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


// NEW: Concise Gratitude Prompt to replace the full Diary widget
Widget _buildGratitudeInput() {
  return Card(
    elevation: 0,
    color: AppColors.secondary,
    margin: const EdgeInsets.only(bottom: 20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed unnecessary 'const' keyword: lib/entry_screen.dart:693 (Already removed)
          const Text('🛐 Gratitude Prompt: What Brightened Your Day?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any extra thoughts about your day...',
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
              // CORRECTED DEPRECATION: lib/entry_screen.dart:707 (was withOpacity)
              hintStyle: TextStyle(color: AppColors.textDark.withAlpha((255 * 0.6).round())),
            ),
            style: const TextStyle(color: AppColors.textDark),
          ),
        ],
      ),
    ),
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Daily Check-in'),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.background,
      // --- START OF HISTORY BUTTON ADDITION ---
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: AppColors.background),
          onPressed: () {
            // Navigation to the HistoryScreen (Requires import at the top of the file)
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        )
      ],
      // --- END OF HISTORY BUTTON ADDITION ---
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Mood Check
          _buildHorizontalMoodSelector(
            title: 'Mood Check: Quick scan — How’s the vibe today?',
            subtitle: 'Select the option that best describes your current energy state.',
            selectedValue: _selectedMood,
            options: moodOptions,
            onChanged: (val) => setState(() => _selectedMood = val),
          ),


          // 2. Sleep Log
          _buildThematicSleepSelector(),


          // 3. Move Report
          _buildMoveGaugeSelector(),
        
          // 4. Glasses of Water Counter
          _buildCounterInput(
            title: '💧 Hydration: Glasses of Water:',
            unit: 'Glasses',
            value: _waterGlasses,
            onChanged: (val) => setState(() => _waterGlasses = val),
          ),


          // 5. Notes (Gratitude Prompt)
          _buildGratitudeInput(),


          const SizedBox(height: 24),


          // Save Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              // UPDATED: Use the new _isSaving flag
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              // UPDATED: Add a loading indicator check
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator(color: AppColors.textDark))
                  : const Text(
                      'Complete Check-in & Earn Energy Badge!',
                      style: TextStyle(fontSize: 18, color: AppColors.textDark),
                    ),
            ),
          ),


          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}
}