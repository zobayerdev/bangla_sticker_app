import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_flutter/features/home_screen/model/pack_model.dart';

void main() {
  test('PacksResponseModel parses API JSON correctly', () {
    final Map<String, dynamic> mockJson = {
      "success": true,
      "count": 1,
      "data": [
        {
          "id": 1,
          "name": "Funny People",
          "identifier": "funny-people-6483dc",
          "tray_icon":
              "https://sticker.zobayer.xyz/uploads/stickers/funny-people-6483dc/tray.png",
          "sticker_count": 6,
          "status": "Ready",
          "stickers": [
            "https://sticker.zobayer.xyz/uploads/stickers/funny-people-6483dc/40c3adc067e3c3ef.webp",
            "https://sticker.zobayer.xyz/uploads/stickers/funny-people-6483dc/10b0bbaec127774a.webp",
          ],
        },
      ],
    };

    final response = PacksResponseModel.fromJson(mockJson);

    expect(response.success, true);
    expect(response.count, 1);
    expect(response.data?.length, 1);

    final pack = response.data?.first;
    expect(pack?.id, 1);
    expect(pack?.name, "Funny People");
    expect(pack?.identifier, "funny-people-6483dc");
    expect(pack?.stickerCount, 6);
    expect(pack?.status, "Ready");
    expect(pack?.stickers?.length, 2);
  });
}
