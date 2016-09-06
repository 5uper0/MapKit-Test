# MapKit-Test

![Alt Text](https://github.com/5uper0/MapKit-Test/blob/master/Screenshots/MapKit-Test.gif)

CoreLocation, MapKit Framework

// Annotation

The app is done as iOS Beginner Course 37-38 lessons MapKit homework with 4 level of difficulty. So I made all the tasks programmatically and will introduce You what I have done overall.

1. Created an array of 30 random users with random Core Location coordinates within selected area on the map. 

2. This area is selected using values of presetted point placed in the center of my native city and a radius presetted as "static" variable.

3. Each user have annotation with info in title - name, last name, and subtitle - date of birth.

4. Created a button which can scale the map to show all users on the screen.

5. Setted custom pictures for every user (male and female) instead of standard pins.

6. Each callout (cloud over the user image) has info button to the right of it. So when You click on it, popover is shown. Popover contains a static table with users name, last name, date of birth, gender and address (internet connection is required).

7. If the app runs on the iPhone, You will see these info as modal presentation.

8. Created and shown an annotation for meeting point with its own custom image.

9. Meeting point is used to move over the map and users are not.

10. When a meeting point falls down on the map, 3 circles are drown around him, with the radius of 5 km, 10 km and 15 km (used overlays).

11. In the top left corner You will see view shows how many users fall into each circle with distance calculated for each user.

12. Made '+' button by tapping which routes will be constructed from random users to the meeting point (as if they want to come to the meeting) and possibilities for them to come are different and depend on how far are they now from that point. If they are closer - 90%, if farther - 10%.

// Аннотация

Приложение создано в качестве домашнего задания к iOS Beginner курсу по 37-38 урокам (MapKit) с 4 уровнями сложности. Я выполнил все условия данного задания и опишу, что у меня получилось.

1. Создан массив из 30 случайных пользователей, наряду с именем и фамилией у каждого из них в качестве свойства есть случайная координата (Core Location) в пределах заданной области.
 
2. Область задана двумя предустановленными значениями: точка в центре моего города и предустановленный радиус.
  
3. У каждого пользователя есть аннотация с информацией об имени, фамилии и дате рождения.
 
4. Добавлена кнопка, которая масштабирует карту таким образом, чтобы все пользователи были видны на экране.
 
5. Вместо пинов на карте использованы кастомные картинки, мужски и женские соответственно полу.
  
6. У каждого колаута (при нажатии на пин пользователя) добавлена инфо кнопка так, что при нажатии на нее, появляется Popover, в котором в виде статической таблицы отображаются имя и фамилия пользователя, год рождения, пол и адрес (требует подключения к интернет).
 
7. В случае если приложение запущено на iPhone, то вместо Popover'а контроллер появляется модально.
  
8. По нажатию на кнопку "+", добавляется аннотация для места встречи (кастомная картинка).
 
9. Место встречи можно перемещать по карте, а пользователей нет.
 
10. Когда место встречи попадает на карту, то вокруг него отображаются 3 круга, с радиусами 5 км, 10 км и 15 км (используйтся Overlays).
 
11. В верхнем левом углу отображается View с количеством студентов попадающих в каждый из кругов. Суть такая, чем дальше пользователь находится, тем меньше вероятность что он придет на встречу. Расстояние от пользователя до места встречи рассчитывается используя функцию для расчета расстояния между точками из MapKit фреймворка.
 
12. На Navigation Bar добавлена кнопка, по нажатию на которую, от случайных пользователей до нее прокладываются маршруты (как будто все стремятся на встречу), притом вероятности генератора разные и зависят от круга, в котором они находятся, если он близко, то 90%, а если далеко - то 10%.
