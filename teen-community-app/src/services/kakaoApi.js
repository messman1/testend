// 카카오 Local API 서비스
const KAKAO_API_KEY = '6c3d9e2d50c653818b7fbee8dcd1b9f5';

// 기본 중심 좌표 (서울 시청 - GPS 실패시 사용)
const DEFAULT_CENTER = {
  x: 126.9784147,  // 경도
  y: 37.5666805    // 위도
};

// 검색 반경 (2km)
const DEFAULT_RADIUS = 2000;

// ============================================
// 청소년 친화적 필터링 설정
// ============================================

// 블랙리스트 키워드 (업소명에 포함되면 제외)
const BLACKLIST_KEYWORDS = [
  // 주류 관련
  '주점', '술집', '바', '호프', '이자카야', '포차', '선술집',
  '맥주', '소주', '와인바', '칵테일', '펍', 'pub', 'bar',
  // 유흥 관련
  '클럽', '나이트', '룸살롱', '단란주점', '유흥', '라운지',
  // 성인 관련
  '성인', '19금', '19세', '어덜트', 'adult',
  // 도박 관련
  '카지노', '도박', '베팅',
  // 담배 관련
  '담배', '시가', '전자담배'
];

// 블랙리스트 카테고리 (카테고리명에 포함되면 제외)
const BLACKLIST_CATEGORIES = [
  '술집', '호프', '요리주점', '나이트클럽', '유흥주점',
  '단란주점', '와인바', '칵테일바', '룸카페', '성인용품'
];

// 카테고리별 검색 키워드 매핑 (청소년 친화적으로 개선)
// 순서: 코인노래방, 방탈출, 보드게임카페, 영화관, 북카페
const CATEGORY_KEYWORDS = {
  karaoke: '코인노래방',
  escape: '방탈출카페',
  board: '보드게임카페',
  movie: '영화관',
  cafe: '북카페'
};

// 추가 검색 키워드 (카테고리당 여러 키워드로 다양한 결과)
const CATEGORY_SUB_KEYWORDS = {
  board: ['보드게임카페', '보드게임방'],
  cafe: ['북카페', '스터디카페']
};

// 카테고리별 이모지
const CATEGORY_ICONS = {
  karaoke: '🎤',
  escape: '🎯',
  board: '🎲',
  movie: '🎬',
  cafe: '📚'
};

// 카테고리별 기본 썸네일 (이미지 검색 실패 시 사용)
const DEFAULT_THUMBNAILS = {
  karaoke: 'https://search1.kakaocdn.net/argon/130x130_85_c/Kp2KXLzRwOd',
  escape: 'https://search1.kakaocdn.net/argon/130x130_85_c/IxxsexaSwPv',
  board: 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY',
  movie: 'https://search1.kakaocdn.net/argon/130x130_85_c/36hQpoTrVZp',
  cafe: 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY'
};

// 이미지 캐시 (API 호출 최소화)
const imageCache = new Map();

// ============================================
// 필터링 함수
// ============================================

function isYouthFriendly(place) {
  const placeName = place.place_name?.toLowerCase() || '';
  const categoryName = place.category_name?.toLowerCase() || '';

  for (const keyword of BLACKLIST_KEYWORDS) {
    if (placeName.includes(keyword.toLowerCase())) {
      console.log(`[필터링] 제외: ${place.place_name} (키워드: ${keyword})`);
      return false;
    }
  }

  for (const category of BLACKLIST_CATEGORIES) {
    if (categoryName.includes(category.toLowerCase())) {
      console.log(`[필터링] 제외: ${place.place_name} (카테고리: ${category})`);
      return false;
    }
  }

  return true;
}

function filterYouthFriendlyPlaces(places) {
  return places.filter(isYouthFriendly);
}

// ============================================
// 이미지 검색 API
// ============================================

// 장소명으로 썸네일 이미지 검색
async function searchPlaceImage(placeName) {
  // 캐시 확인
  if (imageCache.has(placeName)) {
    return imageCache.get(placeName);
  }

  try {
    const params = new URLSearchParams({
      query: placeName,
      size: '1'
    });

    const response = await fetch(
      `https://dapi.kakao.com/v2/search/image?${params}`,
      {
        headers: {
          'Authorization': `KakaoAK ${KAKAO_API_KEY}`
        }
      }
    );

    if (!response.ok) {
      throw new Error(`이미지 검색 실패: ${response.status}`);
    }

    const data = await response.json();

    if (data.documents && data.documents.length > 0) {
      const thumbnailUrl = data.documents[0].thumbnail_url;
      imageCache.set(placeName, thumbnailUrl);
      return thumbnailUrl;
    }

    return null;
  } catch (error) {
    console.error('이미지 검색 오류:', error);
    return null;
  }
}

// 여러 장소의 썸네일을 병렬로 가져오기
async function fetchThumbnails(places, category) {
  const defaultThumb = DEFAULT_THUMBNAILS[category] || null;

  const thumbnailPromises = places.map(async (place) => {
    const thumbnail = await searchPlaceImage(place.place_name);
    return {
      ...place,
      thumbnail: thumbnail || defaultThumb
    };
  });

  return Promise.all(thumbnailPromises);
}

// ============================================
// API 호출 함수
// ============================================

async function searchPlaces(keyword, options = {}) {
  const {
    x = DEFAULT_CENTER.x,
    y = DEFAULT_CENTER.y,
    radius = DEFAULT_RADIUS,
    size = 15
  } = options;

  const params = new URLSearchParams({
    query: keyword,
    x: x.toString(),
    y: y.toString(),
    radius: radius.toString(),
    size: size.toString()
  });

  try {
    const response = await fetch(
      `https://dapi.kakao.com/v2/local/search/keyword.json?${params}`,
      {
        headers: {
          'Authorization': `KakaoAK ${KAKAO_API_KEY}`
        }
      }
    );

    if (!response.ok) {
      throw new Error(`API 요청 실패: ${response.status}`);
    }

    const data = await response.json();
    const filteredPlaces = filterYouthFriendlyPlaces(data.documents);

    return filteredPlaces;
  } catch (error) {
    console.error('장소 검색 오류:', error);
    return [];
  }
}

// 카테고리별 장소 검색 (썸네일 포함)
async function searchByCategory(category, options = {}) {
  const keyword = CATEGORY_KEYWORDS[category];
  if (!keyword) {
    console.error('알 수 없는 카테고리:', category);
    return [];
  }

  const requestedSize = options.size || 10;
  const includeThumbnails = options.includeThumbnails !== false; // 기본값 true

  let places = await searchPlaces(keyword, { ...options, size: 15 });

  // 추가 키워드로 더 다양한 결과 수집
  const subKeywords = CATEGORY_SUB_KEYWORDS[category] || [];
  if (subKeywords.length > 0 && places.length < requestedSize) {
    for (const subKeyword of subKeywords) {
      if (places.length >= requestedSize) break;
      const morePlaces = await searchPlaces(subKeyword, { ...options, size: 5 });
      for (const place of morePlaces) {
        if (!places.find(p => p.id === place.id)) {
          places.push(place);
        }
      }
    }
  }

  places = places.slice(0, requestedSize);

  // 썸네일 가져오기 (옵션)
  if (includeThumbnails) {
    places = await fetchThumbnails(places, category);
  }

  // 앱에서 사용하기 쉬운 형태로 변환
  return places.map(place => ({
    id: place.id,
    name: place.place_name,
    category: category,
    location: extractLocation(place.address_name),
    address: place.road_address_name || place.address_name,
    phone: place.phone || '',
    distance: Math.round(parseInt(place.distance) / 100) / 10 + 'km',
    icon: CATEGORY_ICONS[category] || '📍',
    thumbnail: place.thumbnail || DEFAULT_THUMBNAILS[category] || null,
    url: place.place_url,
    x: parseFloat(place.x),
    y: parseFloat(place.y),
    categoryDetail: place.category_name
  }));
}

// 모든 카테고리 장소 가져오기
async function getAllPlaces(options = {}) {
  const categories = Object.keys(CATEGORY_KEYWORDS);
  const allPlaces = [];

  for (const category of categories) {
    const places = await searchByCategory(category, { ...options, size: options.size || 5 });
    allPlaces.push(...places);
  }

  return allPlaces;
}

// 주소에서 동네 이름 추출
function extractLocation(address) {
  if (!address) return '서초구';
  const parts = address.split(' ');
  const dong = parts.find(p => p.endsWith('동'));
  return dong || parts[2] || '서초구';
}

// 거리 계산 (미터 단위)
function formatDistance(meters) {
  if (meters < 1000) {
    return `${meters}m`;
  }
  return `${(meters / 1000).toFixed(1)}km`;
}

export {
  searchPlaces,
  searchByCategory,
  getAllPlaces,
  searchPlaceImage,
  formatDistance,
  isYouthFriendly,
  CATEGORY_KEYWORDS,
  CATEGORY_ICONS,
  DEFAULT_THUMBNAILS,
  DEFAULT_CENTER,
  DEFAULT_RADIUS,
  BLACKLIST_KEYWORDS,
  BLACKLIST_CATEGORIES
};
