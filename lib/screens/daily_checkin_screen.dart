// lib/screens/daily_checkin_screen.dart
import 'package:flutter/material.dart';
// NOTE: Assuming AppColors is available via this path
import 'package:wellbeing_mobile_app/theme/app_colors.dart';

// --- THEMATIC DATA MODELS FOR SURVEY OPTIONS ---

// 1. Mood Check (Horizontal Cards) - FINALIZED
const List<Map<String, dynamic>> moodOptions = [
  {'value': 1, 'label': 'Disaster Mode', 'subtitle': 'Rough day, but still standing.', 'color': Color(0xFFE57373), 'icon': '🚨'}, // Red
  {'value': 2, 'label': 'Low Battery', 'subtitle': 'Energy’s low; but still online.', 'color': Color(0xFFFFB74D), 'icon': '🔋'}, // Orange
  {'value': 3, 'label': 'Cruise Control', 'subtitle': 'Keeping pace, autopilot engaged.', 'color': Color(0xFFFFEB3B), 'icon': '🚗'}, // Yellow
  {'value': 4, 'label': 'Feeling Solid', 'subtitle': 'Focused and calm; just executing.', 'color': Color(0xFF64B5F6), 'icon': '👍'}, // Blue
  {'value': 5, 'label': 'Absolutely Stellar', 'subtitle': 'Running on pure momentum, everything’s clicking.', 'color': Color(0xFF81C784), 'icon': '✨'}, // Green
];

// 2. Sleep Log Labels (Custom Selector) - Scale 1-4
// REVERTED to use EMOJI ICONS
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

class WellbeingEntry {
  final int mood;
  final int sleepRating;
  final int exerciseValue;
  final int waterGlasses;
  final String notes;

  WellbeingEntry({
    required this.mood,
    required this.sleepRating,
    required this.exerciseValue,
    required this.waterGlasses,
    required this.notes,
  });

  void save() {
    // print('Entry Saved: Mood $mood, Sleep $sleepRating, Exercise Value $exerciseValue, Water $waterGlasses, Notes: ${notes.isEmpty ? 'N/A' : notes}'); // ANALYZER: Avoid printing in production code
  }
}

class DailyCheckinScreen extends StatefulWidget {
  // Correct and only constructor for this class
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  // State variables set to 0 (non-valid choice) to prevent initial highlighting
  int _selectedMood = 0;      
  int _selectedSleep = 0;     
  int _selectedExercise = 0;  
  int _waterGlasses = 0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final entry = WellbeingEntry(
      mood: _selectedMood,
      sleepRating: _selectedSleep,
      exerciseValue: _selectedExercise,
      waterGlasses: _waterGlasses,
      notes: _notesController.text,
    );
    entry.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wellbeing entry saved!')),
    );
    Navigator.pop(context); 
  }

  // --- WIDGET 1: Horizontal Mood Selector (Mood Check) ---
  Widget _buildHorizontalMoodSelector({
    required String title,
    required String subtitle,
    required int selectedValue,
    required List<Map<String, dynamic>> options,
    required ValueChanged<int> onChanged,
  }) {
    final bool isAnySelected = selectedValue > 0;
    
    final Map<String, dynamic>? selectedOption = options.cast<Map<String, dynamic>?>().firstWhere(
      (opt) => opt?['value'] == selectedValue,
      orElse: () => null,
    );
    
    // Default text/icon when nothing is selected
    final String statusLabel = isAnySelected ? selectedOption!['label'] as String : 'No mood selected';
    final String statusSubtitle = isAnySelected ? selectedOption!['subtitle'] as String : 'Tap a pill below to register your energy level.';
    final String statusIcon = isAnySelected ? selectedOption!['icon'] as String : '🤔';
    final Color statusColor = isAnySelected ? selectedOption!['color'] as Color : AppColors.textSubtle;


    return Card(
      elevation: 0,
      color: AppColors.secondary,  
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 12),
            
            // ADDED: Status Display (for better visual size consistency with other sections)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                  statusIcon,
                  style: TextStyle(fontSize: 32, color: statusColor),
                ),
              title: Text(
                'Status: $statusLabel',
                style: TextStyle(fontWeight: FontWeight.bold, color: isAnySelected ? AppColors.primaryColor : AppColors.textSubtle),
              ),
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
                children: options.map((option) {
                  final isSelected = option['value'] == selectedValue;
                  
                  final Color selectedPillColor = option['color'] as Color;  
                  
                  // Set the card color to the specific mood color regardless of selection state.
                  final cardColor = selectedPillColor;  
                  
                  // Text contrast logic
                  final bool isLightColor = option['value'] >= 2 && option['value'] <= 4;  
                  final textColor = isLightColor ? AppColors.textDark : AppColors.background;  
                  
                  // Border will only show the primary color when selected.
                  // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
                  final borderColor = isSelected ? AppColors.primaryColor : cardColor.withAlpha((255 * 0.9).round());

                  return Padding(
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
                            // Consistently active base color for all dots
                            // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
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
            // UPDATED TITLE
            const Text(
              'Movement Mission: Your Daily Activity Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            // NEW SUBTITLE/PROMPT
            const Text(
              'Did you move your body yesterday? Log your minutes below.',
              style: TextStyle(fontSize: 14, color: AppColors.textSubtle),
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
              title: Text(
                selectedOption['label'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
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
                              // Use the specific color from moveOptions for the active bar segment
                              // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
                              color: isActivated  
                                  ? option['color'].withAlpha((255 * 0.8).round())  
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
      // This section should technically not be reachable due to the button limit, 
      // but is kept as a safeguard for manual data entry.
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            
            // --- NEW: Dynamic Status Display ---
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                icon,
                style: TextStyle(fontSize: 32, color: statusColor),
              ),
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
                  onPressed: () => onChanged(value > 0 ? value - 1 : 0),
                  // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
                  backgroundColor: AppColors.primaryColor.withAlpha((255 * 0.8).round()),
                  child: const Icon(Icons.remove, color: AppColors.background),
                ),
                
                // Value Display (Glasses + Liters)
                RichText(
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
                  // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
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
                // ANALYZER: Fixing deprecated_member_use: withOpacity should be avoided for colors
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Mood Check (Horizontal Cards) - NOW WITH IMPROVED ALIGNMENT AND HEIGHT
            _buildHorizontalMoodSelector(
              title: 'Mood Check: Quick scan — How’s the vibe today?',
              subtitle: 'Select the option that best describes your current energy state.',
              selectedValue: _selectedMood,
              options: moodOptions,
              onChanged: (val) => setState(() => _selectedMood = val),
            ),

            // 2. Sleep Log (Custom Thematic Selector) - REVERTED TO EMOJIS
            _buildThematicSleepSelector(),

            // 3. Move Report (Thematic Gauge Selector) - UPDATED TITLE/SUBTITLE & REMOVED NUMBERS
            _buildMoveGaugeSelector(),
            
            // 4. Glasses of Water Counter - NOW WITH DYNAMIC STATUS & LITERS
            _buildCounterInput(
              title: '💧 Hydration: Glasses of Water:',
              unit: 'Glasses',
              value: _waterGlasses,
              onChanged: (val) => setState(() => _waterGlasses = val),
            ),

            // 5. Notes (Gratitude Prompt) - REPLACED FULL DIARY WITH CONCISE PROMPT
            _buildGratitudeInput(),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Complete Check-in & Earn Energy Badge!',
                  style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Placeholder for Fun Reward Card
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '✨ You\'ve earned today\'s Energy Badge! (Animation Placeholder) ✨',
                style: TextStyle(color: AppColors.textSubtle, fontStyle: FontStyle.italic),
              )
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}