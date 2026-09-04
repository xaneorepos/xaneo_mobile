import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/avatar_cache_service.dart';

void main() {
  test('avatar cache key is stable when authorization token changes', () {
    const first =
        'https://xaneo.test/media/avatar.png?size=large&token=old-token';
    const second =
        'https://xaneo.test/media/avatar.png?token=new-token&size=large';

    expect(
      AvatarCacheService.cacheKeyFor(first),
      AvatarCacheService.cacheKeyFor(second),
    );
    expect(AvatarCacheService.cacheKeyFor(first), isNot(contains('token')));
  });

  test('different avatar URLs use different cache entries', () {
    expect(
      AvatarCacheService.cacheKeyFor(
        'https://xaneo.test/media/avatar-v1.png',
      ),
      isNot(
        AvatarCacheService.cacheKeyFor(
          'https://xaneo.test/media/avatar-v2.png',
        ),
      ),
    );
  });
}
