-- Вставляем данные для ролей
INSERT INTO roles (role_name) VALUES ('ADMIN');
INSERT INTO roles (role_name) VALUES ('USER');

-- Вставляем пользователей
INSERT INTO users (user_role, user_name, user_email, user_password) 
VALUES (2, 'User1', 'user1@example.com', hash_password('password1'));
INSERT INTO users (user_role, user_name, user_email, user_password) 
VALUES (2, 'User2', 'user2@example.com', hash_password('password2'));
INSERT INTO users (user_role, user_name, user_email, user_password) 
VALUES (2, 'User3', 'user3@example.com', hash_password('пароль3'));
INSERT INTO users (user_role, user_name, user_email, user_password) 
VALUES (2, 'User4', 'user4@example.com', hash_password('123456789'));

-- Вставляем данные об исполнителях
INSERT INTO artists (artist_name, artist_description) 
VALUES ('The Beatles', 'Legendary rock band from the UK');
INSERT INTO artists (artist_name, artist_description) 
VALUES ('Ariana Grande', 'American singer and actress');
INSERT INTO artists (artist_name, artist_description) 
VALUES ('Imagine Dragons', 'American pop rock band');

-- Вставляем данные о жанрах музыки
INSERT INTO genres (genre_name) VALUES ('Rock');
INSERT INTO genres (genre_name) VALUES ('Pop');
INSERT INTO genres (genre_name) VALUES ('Jazz');

-- Вставляем данные о песнях с привязкой к исполнителям и жанрам
INSERT INTO songs (song_title, artist_id, genre_id, song_path, added_date) 
VALUES ('Hey Jude', 1, 1, 'path/to/hey_jude.mp3', TO_DATE('2024-12-01', 'YYYY-MM-DD'));
INSERT INTO songs (song_title, artist_id, genre_id, song_path, added_date) 
VALUES ('Problem', 2, 2, 'path/to/problem.mp3', TO_DATE('2024-11-28', 'YYYY-MM-DD'));
INSERT INTO songs (song_title, artist_id, genre_id, song_path, added_date) 
VALUES ('Radioactive', 3, 1, 'path/to/radioactive.mp3', TO_DATE('2024-11-20', 'YYYY-MM-DD'));

-- Вставляем данные о плейлистах
INSERT INTO playlists (playlist_name, user_id) 
VALUES ('LOK Favorite Songs', 1);
INSERT INTO playlists (playlist_name, user_id) 
VALUES ('Rock Classics', 2);

-- Вставляем данные о песнях в плейлисты
INSERT INTO playlist_song (playlist_id, song_id) 
VALUES (1, 1);
INSERT INTO playlist_song (playlist_id, song_id) 
VALUES (1, 3);
INSERT INTO playlist_song (playlist_id, song_id) 
VALUES (2, 2);
