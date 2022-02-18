// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadFile(String fileName, String fileContents) async {
  // Create a Blob to download from the CSV data
  final csvBlob = html.Blob([fileContents], 'text/plain', 'native');
  // Create and click on the Anchor element to download the file
  final webAnchor =
      html.AnchorElement(href: html.Url.createObjectUrlFromBlob(csvBlob))
        ..setAttribute("download", fileName)
        ..click();
  //Remove the web anchor from the page
  webAnchor.remove();
}
