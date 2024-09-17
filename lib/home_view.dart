import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import "package:universal_html/html.dart" as html;

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    super.key,
  });

  @override
  FileUploadWidgetState createState() => FileUploadWidgetState();
}

class FileUploadWidgetState extends State<FileUploadWidget> {
  String? fileName; // To hold the selected file name
  String? errorMessage; // To hold any error messages
  Uint8List? fileData; // To hold the selected file data
  String? serverResponse; // To display server response
  double progress = 0.0; // To track the upload progress
  bool isUploading = false; // To track if the file is currently uploading

  String url =
      "https://hr.computerengine.net/EmpMobile/Jobs/SmartUpload/uploadexmple.asp";

  // Method to pick file
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video, // We are only picking video files
        withData: true, // Return the file data
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          fileName = result.files.single.name;
          fileData = result.files.single.bytes;
          errorMessage = null; // Reset error message if successful
        });
        log("File picked: $fileName");
      } else {
        setState(() {
          errorMessage = "No file selected.";
          fileName = null;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Failed to pick file: $error";
      });
    }
  }

  // Method to upload file after picking
// Method to upload file after picking
  Future<void> uploadFile() async {
    if (fileData == null) {
      setState(() {
        errorMessage = "No file data to upload.";
      });
      return;
    }

    setState(() {
      progress = 0.0;
      isUploading = true;
      serverResponse = null; // Clear previous server responses
    });

    try {
      var request = html.HttpRequest();
      request.open('POST', url, async: true);
      log("Opened HTTP request for URL: $url");

      var formData = html.FormData();
      var blob = html.Blob([fileData!]);
      formData.appendBlob('FILE1', blob, '$fileName.mp4');

      // Track the progress of the file upload
      request.upload.onProgress.listen((event) {
        if (event.lengthComputable) {
          setState(() {
            progress = event.loaded! / event.total!; // Update progress value
          });
        }
      });

      // Handle when the upload is done
      request.onLoadEnd.listen((_) {
        setState(() {
          isUploading = false; // Hide the progress bar once done
        });

        if (request.readyState == html.HttpRequest.DONE) {
          log("Response status code: ${request.status}");

          if (request.status == 200) {
            setState(() {
              serverResponse = request.responseText; // Show server response
              errorMessage = null; // Clear any previous error messages
              log("Upload successful. Server response: $serverResponse");
            });
          } else {
            setState(() {
              errorMessage =
                  "Upload failed with status code: ${request.status}\n${request.responseText}";
              serverResponse =
                  request.responseText; // Show server response on failure
            });
          }
        } else {
          setState(() {
            errorMessage = "Unexpected readyState: ${request.readyState}";
          });
        }
      });

      request.onError.listen((event) {
        setState(() {
          errorMessage =
              "Request error with status code: ${request.status}\n${event.toString()}";
          isUploading = false; // Stop showing the progress bar if error occurs
        });
      });

      request.send(formData);
      log("Request sent.");
    } catch (error) {
      setState(() {
        errorMessage = "Upload exception: $error";
        isUploading = false;
      });
    }
  }

  // Method to load a file from assets
  Future<void> loadFileFromAssets(String assetPath) async {
    try {
      ByteData assetData = await rootBundle.load(assetPath);
      setState(() {
        fileName = assetPath.split('/').last;
        fileData = assetData.buffer.asUint8List();
        errorMessage = null; // Reset error message if successful
      });
      log("Asset file loaded: $fileName");
    } catch (error) {
      setState(() {
        errorMessage = "Failed to load asset file: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'File Uploader',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF153b50),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button to pick file from device
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF153b50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: pickFile, // Calls the file picker
                child: const Text(
                  'Pick File from Device',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Button to load file from assets
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => loadFileFromAssets(
                    'assets/videos/splash.mp4'), // Example path from assets
                child: const Text(
                  'Load File from Assets',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (fileName != null) ...[
                Text(
                  'File selected: $fileName',
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3b3355),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: uploadFile, // Calls the file upload method
                  child: const Text(
                    'Upload File',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              if (isUploading)
                SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      const Text(
                        'Uploading...',
                        style: TextStyle(
                          color: Color(0xFF153b50),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      LinearProgressIndicator(
                        value: progress,
                        color: const Color(0xFF153b50),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign
                      .center, // Center-align text for better readability
                ),
              ],
              if (serverResponse != null) ...[
                const SizedBox(height: 16.0),
                SizedBox(
                  width: 400,
                  child: Text(
                    textAlign: TextAlign.center,
                    'Server Response: $serverResponse',
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
