
import 'package:gradpro/models/image_response.dart';
import 'package:gradpro/services/internet_services.dart';

class ImageService {
  static final ImageService _imageService = ImageService._internal();
  final InternetService _internetService = InternetService();
  static const _token = "73d49576123de8c5593ca58936bdad54";
  final _imagehost = "https://api.imgbb.com/1/upload";

  factory ImageService() {
    return _imageService;
  }

  ImageService._internal();

  Future<ImageResponse> postImage(String base64Image) async {
    final response = await _internetService.postFormDataImage(_imagehost, {
      "key": _token,
      "image":base64Image
    });
    final ImageResponse imageData = imageResponseFromJson(response.body);
    return imageData;
  }
}
