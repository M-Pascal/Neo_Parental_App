# API Integration Guide

## Overview

The NeoParental app has been integrated with the prediction API to analyze baby cry audio files and display results in a beautiful popup dialog.

## API Details

- **Base URL**: `https://neoparental-fast-api.onrender.com`
- **Endpoint**: `/predict`
- **Method**: POST (multipart/form-data)
- **Documentation**: https://neoparental-fast-api.onrender.com/docs

## Implementation

### 1. Prediction Service (`lib/services/prediction_service.dart`)

A new service class that handles:

- Uploading audio files to the API
- Parsing the response
- Error handling for network issues
- Formatting timestamp and processing time

**Key Features:**

- Multipart file upload
- JSON response parsing
- Custom exception handling
- Time formatting utilities

### 2. Updated Record Screen (`lib/Screens/record.dart`)

The upload functionality now:

1. Selects audio file from device
2. Shows loading dialog ("Analyzing audio file...")
3. Sends file to API
4. Displays prediction results in a beautiful popup

### 3. Prediction Popup Dialog

Beautiful gradient dialog showing:

- **Predicted Label**: The baby's cry type (e.g., "Tired/Sleepy")
- **Time**: Analysis timestamp in HH:MM format
- **Recommendation**: Lorem ipsum text (20 words max)

**Design Features:**

- Gradient header (orange theme)
- Icon-based result rows
- Clean white content area
- Rounded corners
- Professional styling

## Response Format

The API returns:

```json
{
  "prediction_value": 4,
  "predicted_label": "Tired/Sleepy",
  "confidence": 100,
  "processing_time": 12.992491,
  "timestamp": "2025-11-02T17:01:29.704527"
}
```

**Displayed in Popup:**

- Prediction: "Tired/Sleepy"
- Time: "17:01"
- Recommendation: "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt."

## User Flow

1. **Select Audio File**

   - User clicks "Select Audio" button
   - File picker opens with audio file filters
   - Selected file name is displayed

2. **Upload & Analyze**

   - User clicks "Upload" button
   - Loading dialog appears: "Analyzing audio file..."
   - File is sent to API endpoint

3. **View Results**

   - Beautiful popup appears with:
     - Success icon and title
     - Predicted baby cry type
     - Analysis time
     - Recommendation text
   - User clicks "OK" to close

4. **Error Handling**
   - Network errors show red snackbar
   - API errors display error message
   - User can retry by selecting file again

## Dependencies Added

### pubspec.yaml

```yaml
dependencies:
  http: ^1.1.0 # For API calls
```

## Testing the Feature

### Prerequisites

1. Run `flutter pub get` to install http package
2. Ensure device has internet connection
3. Test audio files should be in supported formats:
   - mp3, wav, m4a, aac, flac, ogg, wma

### Test Steps

1. Open the app
2. Login with any credentials
3. Navigate to "Audio" tab (Record page)
4. Click "Select Audio"
5. Choose an audio file
6. Click "Upload"
7. Wait for analysis (loading dialog)
8. View prediction popup
9. Click "OK" to close

### Expected Results

- Loading dialog shows while processing
- Popup appears with prediction results
- All data is formatted correctly
- Popup is visually appealing
- No crashes or errors

## Error Scenarios

### Network Error

- **Message**: "Network error. Please check your internet connection."
- **Display**: Red snackbar at bottom
- **Action**: Check internet and retry

### API Error

- **Message**: "Prediction failed: [status code] - [error details]"
- **Display**: Red snackbar at bottom
- **Action**: Check file format and retry

### File Selection Cancelled

- **Message**: "No file selected."
- **Display**: Orange snackbar
- **Action**: Try selecting file again

## Code Structure

```
lib/
├── services/
│   └── prediction_service.dart      # API service
└── Screens/
    └── record.dart                   # Updated UI with popup
```

## Future Enhancements

1. **Save Results to History**

   - Store predictions locally
   - Add to history page
   - Enable result sharing

2. **Better Recommendations**

   - Replace Lorem ipsum with real advice
   - Contextual tips based on prediction
   - Multi-language support

3. **Progress Indicator**

   - Show upload percentage
   - Display processing time
   - Add cancel option

4. **Offline Support**
   - Queue uploads when offline
   - Sync when connection restored
   - Cache recent predictions

## Troubleshooting

### Issue: "Package http not found"

**Solution**: Run `flutter pub get` in the neoparent directory

### Issue: API timeout

**Solution**:

- Check internet connection
- Verify API is online at https://neoparental-fast-api.onrender.com/docs
- Try with smaller audio file

### Issue: File path is null

**Solution**:

- Ensure file picker has storage permissions
- Try selecting file again
- Check file is not corrupted

### Issue: Popup doesn't show

**Solution**:

- Check console for errors
- Verify API response is valid JSON
- Ensure context is still mounted

## Notes

- All audio files are sent to external API
- No local storage of predictions (yet)
- Internet connection required
- API response time varies by file size
- Supported audio formats: mp3, wav, m4a, aac, flac, ogg, wma
