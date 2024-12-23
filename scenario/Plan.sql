-- 1) ������� roles
SELECT * FROM roles;
DELETE FROM roles;

-- 2) ������� users
SELECT * FROM users;
DELETE FROM users;

-- 3) ������� artists
SELECT * FROM artists;
DELETE FROM artists;

-- 4) ������� genres
SELECT * FROM genres;
DELETE FROM genres;

-- 5) ������� songs
SELECT * FROM songs;
DELETE FROM songs;

-- 6) ������� playlists
SELECT * FROM playlists;
DELETE FROM playlists;

-- 7) ������� playlist_song
SELECT * FROM playlist_song;
DELETE FROM playlist_song;

-- 1) ������� roles
ALTER TABLE roles MODIFY role_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 2) ������� users
ALTER TABLE users MODIFY user_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 3) ������� artists
ALTER TABLE artists MODIFY artist_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 4) ������� genres
ALTER TABLE genres MODIFY genre_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 5) ������� songs
ALTER TABLE songs MODIFY song_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 6) ������� playlists
ALTER TABLE playlists MODIFY playlist_id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);

-- 7) ������� playlist_song
ALTER TABLE playlist_song MODIFY id GENERATED BY DEFAULT AS IDENTITY (START WITH 1);
-------
--admin
-------
EXEC add_role('Ghggbg');
EXEC delete_role(11);
EXEC update_role(11, '����� ����');
EXEC get_all_roles;

EXEC add_artist('�������', '�����');
EXEC delete_artist(12);
EXEC update_artist(12, 'bbb', '');
EXEC get_all_artists;

EXEC add_playlist('��� ����� ����������', 5);
EXEC delete_playlist(3);
EXEC update_playlist(3, 'Updated Playlist', 2);
EXEC get_all_playlists;

EXEC add_song('Song Titl������eg', 2, 2, '/pathg/t��o�/song.mp3');
EXEC delete_song(8);
EXEC update_song(4, 'Updated Song1111', 1, 1, '/path/to/song.mp3', TO_DATE('2020-12-12', 'YYYY-MM-DD'));
EXEC update_song(6, 'Updated Song1111', 1, 1, '/path/to/song.mp3', SYSDATE);
EXEC get_all_songs;
EXEC get_songs_sorted_by_date;

EXEC add_user('�f��f���', 'ivan@exmple.com', 'password123', 2);
EXEC delete_user(8);
EXEC update_user(8, '������ ����', 'ivanov@example.com', 'newpassword', 2);
EXEC get_all_users;

EXEC add_genre('Hip-Hop');
EXEC delete_genre(5);
EXEC update_genre(5, '');
EXEC get_all_genres;

BEGIN
    add_song_to_playlist(1, 22);  -- 1 � ��� ID ���������, 2 � ��� ID �����
END;
BEGIN
    remove_song_from_playlist(1, 22);  -- 1 � ��� ID ���������, 2 � ��� ID �����
END;
BEGIN
    get_songs_from_playlist(1);  
END;
------
--user
------
BEGIN
    LOK_ADMIN.get_all_roles;
END;
BEGIN
    LOK_ADMIN.get_all_artists;
END;
BEGIN
    LOK_ADMIN.get_all_songs;
END;
BEGIN
    LOK_ADMIN.get_songs_sorted_by_date;
END;
BEGIN
    LOK_ADMIN.add_playlist_user('��� ����� ���hhh�������', 4);
END;
BEGIN
    LOK_ADMIN.delete_playlist_user(1, 4);  -- 1 - ID ��������� ��� ��������, 4 - user_id
END;
BEGIN
    LOK_ADMIN.update_playlist_user(7, '����������� ��������', 4);  -- 1 - ID ���������, '����������� ��������' - ����� ���, 4 - user_id
END;
BEGIN
    LOK_ADMIN.add_song_to_playlist_user(p_playlist_id => 1, p_song_id => 4, p_user_id => 1);
END;
BEGIN
    LOK_ADMIN.remove_song_from_playlist_user(p_playlist_id => 1, p_song_id => 2, p_user_id => 4);
END;
BEGIN
    LOK_ADMIN.get_songs_from_playlist_user(p_playlist_id => 1, p_user_id => 1);
END;





