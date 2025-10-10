# Znuny-InitiatorEmail

Модуль для Znuny 6.2, который при создании тикета из письма:
- проверяет отправителя (например, `testsender@domain.zone`);
- извлекает первую строку вида `Email: sender.name@domain.zone` из тела письма;
- записывает найденный адрес в динамическое поле `InitiatorEmail`.

## Установка
1. Соберите пакет `.opm` из `.sopm` файла:
   ```bash
   bin/otrs.Console.pl Dev::Package::Build SOPM/Znuny-InitiatorEmail.sopm
