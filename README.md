# MapKit-Test

 Ученик.
 
 1. Создайте массив из 10 - 30 рандомных студентов, прямо как раньше, только в этот раз пусть у них наряду с именем и фамилией будет еще и координата. Можете использовать структуру координаты, а можете просто два дабла - лонгитюд и латитюд.
 
 2. Координату генерируйте так, установите центр например в вашем городе и просто генерируйте небольшие отрицательные либо положительные числа, чтобы рандомно получалась координата от центра в пределах установленного радиуса.
 
 (Ну а если совсем не получается генерировать координату, то просто ставьте им заготовленные координаты - это не главное)
 
 3. После того, как вы сгенерировали своих студентов, покажите их всех на карте, причем в титуле пусть будет Имя и Фамилия а в сабтитуле год рождения. Можете для каждого студента создать свою аннотацию, а можете студентов подписать на протокол аннотаций и добавить их на карту напрямую - как хотите :)
 
  Студент.
 
 4. Добавьте кнопочку, которая покажет всех студентов на экране.
 
 5. Вместо пинов на карте используйте свои кастомные картинки, причем если студент мужского пола, то картинка должна быть одна, а для девушек другая.
 
 Мастер
 
 6. У каждого колаута (этого облачка над пином) сделайте кнопочку информации справа так, что когда я на нее нажимаю вылазит поповер, в котором в виде статической таблицы находится имя и фамилия студента, год рождения, пол и самое главное адрес.
 
 7. В случае если это телефон, то вместо поповера контроллер должен вылазить модально.
 
 Супермен
 
 8. Создайте аннотацию для места встречи и показывайте его на карте новымой соответствующей картинкой
 
 9. Место встречи можно перемещать по карте, а студентов нет
 
 10. Когда место встречи бросается на карту, то вокруг него надо рисовать 3 круга, с радиусами 5 км, 10 км и 15 км (используйте оверлеи)
 
 11. На какой-то полупрозрачной вьюхе в одном из углов вам надо показать сколько студентов попадают в какой круг. Суть такая, чем дальше студент живет, тем меньше вероятность что он придет на встречу. Расстояние от студента до места встречи рассчитывайте используя функцию для расчета расстояния между точками, поищите ее в фреймворке :)
 
 12. Сделайте на навигейшине кнопочку, по нажатию на которую, от рандомных студентов до нее будут проложены маршруты (типо студенты идут на сходку), притом вероятности генератора разные, зависит от круга, в котором они находятся, если он близко, то 90%, а если далеко - то 10%
