Доработка задачи "Prog9" для изучения работы с пультом (пульт от телевизора SUPRA) и дисплеем LCD 1602A:
"Разработать устройство, предназначенное для воспроизведения простых одноголосых мелодий, записанных в память программ на этапе программирования. Мелодия воспроизводится при нажатии цифровых кнопок на пульте SUPRA. Каждой из кнопок должна соответствовать своя мелодия. При нажатии кнопки "0" воспроизведение мелодий прекращается. Кроме того, код нажатой клавиши отображается на дисплее LCD1602A".

Пульт работает по протоколу, похожему на "Протокол JVC" (https://www.sbprojects.net/knowledge/ir/jvc.php).
Отличается только длительность импульсов.

8-битный адрес и 8-битная длина команды.
Битовое время (включая время паузы после импульса) 2мс ("0") или 3мс ("1").
Сообщение запускается пакетом AGC 3мс. Затем за этим пакетом AGC следует интервал в 3мс, за которым следуют Адрес и команда. Общее время передачи является переменным, поскольку время передачи битов является переменным.
