import { supabase } from './supabase'

/**
 * 내 친구 목록 조회
 */
export async function getMyFriends(userId) {
  try {
    const { data, error } = await supabase
      .from('friends')
      .select(`
        id,
        friend_id,
        created_at,
        friend:friend_id (
          id,
          email,
          nickname,
          level,
          points
        )
      `)
      .eq('user_id', userId)

    if (error) throw error

    // friend 객체를 평탄화
    return data.map(item => ({
      id: item.id,
      ...item.friend,
      created_at: item.created_at
    }))
  } catch (error) {
    console.error('친구 목록 조회 실패:', error)
    throw error
  }
}

/**
 * 받은 친구 요청 목록 조회
 */
export async function getReceivedFriendRequests(userId) {
  try {
    const { data, error } = await supabase
      .from('friend_requests')
      .select(`
        id,
        from_user_id,
        status,
        created_at,
        from_user:from_user_id (
          id,
          email,
          nickname,
          level,
          points
        )
      `)
      .eq('to_user_id', userId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })

    if (error) throw error

    // from_user 객체를 평탄화
    return data.map(item => ({
      id: item.id,
      ...item.from_user,
      status: item.status,
      created_at: item.created_at
    }))
  } catch (error) {
    console.error('친구 요청 목록 조회 실패:', error)
    throw error
  }
}

/**
 * 보낸 친구 요청 목록 조회
 */
export async function getSentFriendRequests(userId) {
  try {
    const { data, error } = await supabase
      .from('friend_requests')
      .select(`
        id,
        to_user_id,
        status,
        created_at,
        to_user:to_user_id (
          id,
          email,
          nickname,
          level
        )
      `)
      .eq('from_user_id', userId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })

    if (error) throw error

    return data.map(item => ({
      id: item.id,
      ...item.to_user,
      status: item.status,
      created_at: item.created_at
    }))
  } catch (error) {
    console.error('보낸 친구 요청 목록 조회 실패:', error)
    throw error
  }
}

/**
 * 이메일로 사용자 검색
 */
export async function searchUserByEmail(email, currentUserId) {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('id, email, nickname, level')
      .eq('email', email)
      .neq('id', currentUserId) // 자기 자신 제외
      .single()

    if (error) {
      if (error.code === 'PGRST116') {
        // No rows found
        return null
      }
      throw error
    }

    return data
  } catch (error) {
    console.error('사용자 검색 실패:', error)
    throw error
  }
}

/**
 * 친구 요청 보내기
 */
export async function sendFriendRequest(fromUserId, toUserEmail) {
  try {
    // 1. 받는 사람 검색
    const toUser = await searchUserByEmail(toUserEmail, fromUserId)

    if (!toUser) {
      throw new Error('해당 이메일을 가진 사용자를 찾을 수 없습니다.')
    }

    // 2. 이미 친구인지 확인
    const { data: existingFriend, error: friendCheckError } = await supabase
      .from('friends')
      .select('id')
      .eq('user_id', fromUserId)
      .eq('friend_id', toUser.id)
      .single()

    if (existingFriend) {
      throw new Error('이미 친구로 등록되어 있습니다.')
    }

    // 3. 이미 요청을 보냈는지 확인
    const { data: existingRequest, error: requestCheckError } = await supabase
      .from('friend_requests')
      .select('id, status')
      .eq('from_user_id', fromUserId)
      .eq('to_user_id', toUser.id)
      .single()

    if (existingRequest && existingRequest.status === 'pending') {
      throw new Error('이미 친구 요청을 보냈습니다.')
    }

    // 4. 친구 요청 보내기
    const { data, error } = await supabase
      .from('friend_requests')
      .insert([
        {
          from_user_id: fromUserId,
          to_user_id: toUser.id,
          status: 'pending'
        }
      ])
      .select()
      .single()

    if (error) throw error

    return data
  } catch (error) {
    console.error('친구 요청 보내기 실패:', error)
    throw error
  }
}

/**
 * 친구 요청 수락하기
 */
export async function acceptFriendRequest(requestId, toUserId) {
  try {
    // 1. 요청 정보 가져오기
    const { data: request, error: fetchError } = await supabase
      .from('friend_requests')
      .select('from_user_id, to_user_id')
      .eq('id', requestId)
      .eq('to_user_id', toUserId)
      .single()

    if (fetchError) throw fetchError

    // 2. 요청 상태를 accepted로 변경
    const { error: updateError } = await supabase
      .from('friend_requests')
      .update({ status: 'accepted', updated_at: new Date().toISOString() })
      .eq('id', requestId)

    if (updateError) throw updateError

    // 3. 양방향으로 friends 테이블에 추가
    const { error: insertError } = await supabase
      .from('friends')
      .insert([
        { user_id: request.from_user_id, friend_id: request.to_user_id },
        { user_id: request.to_user_id, friend_id: request.from_user_id }
      ])

    if (insertError) throw insertError

    return true
  } catch (error) {
    console.error('친구 요청 수락 실패:', error)
    throw error
  }
}

/**
 * 친구 요청 거절하기
 */
export async function rejectFriendRequest(requestId, toUserId) {
  try {
    const { error } = await supabase
      .from('friend_requests')
      .update({ status: 'rejected', updated_at: new Date().toISOString() })
      .eq('id', requestId)
      .eq('to_user_id', toUserId)

    if (error) throw error

    return true
  } catch (error) {
    console.error('친구 요청 거절 실패:', error)
    throw error
  }
}

/**
 * 친구 삭제하기
 */
export async function removeFriend(userId, friendId) {
  try {
    // 양방향으로 삭제
    const { error } = await supabase
      .from('friends')
      .delete()
      .or(`and(user_id.eq.${userId},friend_id.eq.${friendId}),and(user_id.eq.${friendId},friend_id.eq.${userId})`)

    if (error) throw error

    return true
  } catch (error) {
    console.error('친구 삭제 실패:', error)
    throw error
  }
}

/**
 * 보낸 친구 요청 취소하기
 */
export async function cancelFriendRequest(requestId, fromUserId) {
  try {
    const { error } = await supabase
      .from('friend_requests')
      .delete()
      .eq('id', requestId)
      .eq('from_user_id', fromUserId)

    if (error) throw error

    return true
  } catch (error) {
    console.error('친구 요청 취소 실패:', error)
    throw error
  }
}
