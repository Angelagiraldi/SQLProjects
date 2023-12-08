/* Retrieve the 5 oldest users based on their registration date. 
We want to reward our longest-standing users. */
SELECT *
FROM users
ORDER BY created_at
LIMIT 5;

/* Determine the most common day of the week when users register. 
This information will guide our ad campaign scheduling. */
SELECT DATE_FORMAT(created_at, '%W') AS 'Day of the Week', COUNT(*) AS 'Total Registrations'
FROM users
GROUP BY 1
ORDER BY 2 DESC;

/* Version 2: Identifying the top 2 most frequent registration days for ad campaign planning. */
SELECT DAYNAME(created_at) AS 'Day', COUNT(*) AS 'Total'
FROM users
GROUP BY DAY
ORDER BY Total DESC
LIMIT 2;

/* Identify inactive users who have never posted a photo. We aim to target them with an email campaign. */
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;

/* Determine the winner of the contest for the most likes on a single photo. */
SELECT users.username, photos.id, photos.image_url, COUNT(*) AS 'Total Likes'
FROM likes
JOIN photos ON photos.id = likes.photo_id
JOIN users ON users.id = likes.user_id
GROUP BY photos.id
ORDER BY 'Total Likes' DESC
LIMIT 1;

/* Version 2: Find the winner of the contest for the most likes on a single photo. */
SELECT 
    username,
    photos.id,
    photos.image_url, 
    COUNT(*) AS 'Total'
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY 'Total' DESC
LIMIT 1;



/* Determine the average number of posts per user - total posts divided by total users. */
SELECT ROUND((SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users), 2) AS 'Average Posts per User';

/* Rank users based on the number of posts from highest to lowest. */
SELECT users.username, COUNT(photos.image_url) AS 'Total Posts'
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 'Total Posts' DESC;

/* Calculate the total number of posts across all users. */
SELECT SUM(user_posts.total_posts_per_user) AS 'Total Posts by Users'
FROM (SELECT users.username, COUNT(photos.image_url) AS total_posts_per_user
      FROM users
      JOIN photos ON users.id = photos.user_id
      GROUP BY users.id) AS user_posts;

/* Count the total number of users who have posted at least once. */
SELECT COUNT(DISTINCT(users.id)) AS 'Total Users with Posts'
FROM users
JOIN photos ON users.id = photos.user_id;

/* Identify the top 5 most commonly used hashtags for brand usage in posts. */
SELECT tags.tag_name, COUNT(photo_tags.tag_id) AS 'Total Uses'
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY 'Total Uses' DESC
LIMIT 5;

/* Find users who have liked every single photo on the site, potentially indicating bot activity. */
SELECT users.id, users.username, COUNT(users.id) AS 'Total Likes by User'
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING 'Total Likes by User' = (SELECT COUNT(*) FROM photos);


/* Identify users who have never commented on a photo. */
SELECT username, comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NULL;

/* Count the total number of users who have never commented on a photo. */
SELECT COUNT(*) AS 'Total Users Without Comments'
FROM (
    SELECT username, comment_text
    FROM users
    LEFT JOIN comments ON users.id = comments.user_id
    GROUP BY users.id
    HAVING comment_text IS NULL
) AS total_users_without_comments;

/* Assess the presence of potential bots or celebrity accounts:
Calculate the percentage of users who either never commented on a photo or have commented on every photo. */
SELECT 
    tableA.total_A AS 'Number Of Users Who Never Commented',
    (tableA.total_A / (SELECT COUNT(*) FROM users)) * 100 AS 'Percentage of Users',
    tableB.total_B AS 'Number Of Users Who Liked Every Photo',
    (tableB.total_B / (SELECT COUNT(*) FROM users)) * 100 AS 'Percentage of Users'
FROM (
    SELECT COUNT(*) AS total_A
    FROM (
        SELECT username, comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NULL
    ) AS total_number_of_users_without_comments
) AS tableA
JOIN (
    SELECT COUNT(*) AS total_B
    FROM (
        SELECT users.id, username, COUNT(users.id) AS total_likes_by_user
        FROM users
        JOIN likes ON users.id = likes.user_id
        GROUP BY users.id
        HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos)
    ) AS total_number_users_likes_every_photos
) AS tableB;

/* Identify users who have commented on a photo at least once. */
SELECT username, comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NOT NULL;

/* Count the total number of users who have commented on a photo. */
SELECT COUNT(*) AS 'Total Users With Comments'
FROM (
    SELECT username, comment_text
    FROM users
    LEFT JOIN comments ON users.id = comments.user_id
    GROUP BY users.id
    HAVING comment_text IS NOT NULL
) AS total_users_with_comments;

/* Assess the presence of potential bots or celebrity accounts:
Calculate the percentage of users who either never commented on a photo or have commented on photos before. */
SELECT 
    tableA.total_A AS 'Number Of Users Who Never Commented',
    (tableA.total_A / (SELECT COUNT(*) FROM users)) * 100 AS 'Percentage of Users',
    tableB.total_B AS 'Number Of Users Who Commented On Photos',
    (tableB.total_B / (SELECT COUNT(*) FROM users)) * 100 AS 'Percentage of Users'
FROM (
    SELECT COUNT(*) AS total_A
    FROM (
        SELECT username, comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NULL
    ) AS total_number_of_users_without_comments
) AS tableA
JOIN (
    SELECT COUNT(*) AS total_B
    FROM (
        SELECT username, comment_text
        FROM users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY users.id
        HAVING comment_text IS NOT NULL
    ) AS total_number_users_with_comments
) AS tableB;
