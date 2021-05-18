# devops-netology

very important fix here

## Игнорируемые файлы для Terraform

Все каталоги с именем .terraform. Файлы с именем вида *.tfstate, *.tfstate.*, crash.log, *.tvars, override.tf, override.tf.json, *_override.tf, *_override.tf.json, .terraformrc, terraform.rc в любых каталогах


## Основные стадии разработки нового продукта/функционала

### 1. Определение требований
Менеджер, руководитель проекта и архитектор общаются с клиентом, определяют функционал и требования к продукту.

### 2. Подготовка к разработке
Руководитель проекта определяет этапы разработки.
Архитектор составляет макет продукта, определяет компоненты и их функции, форматы хранения данных, схему взаимодействия между компонентами. Вместе с девопсом определяют конкретные продукты, используемые в качестве компонентов.
Девопс описывает и готовит среду окружения для продукта. Создает проект разработки в средствах CI/CD, раздает доступ разработчикам.

### 3. Разработка
Главный разработчик распределяет задачи по кодированию, разработчики пишут код.
Тестировщики пишут тесты.
Девопс совместно с разработчиками и тестировщиками готовит образы, ресурсы, сервисы, настраивает параметры управляющих сущностей для запуска приложений. Девопс запускает и отключает тестовые среды, управляет доступом, проверяет данные мониторинга, траблешутит проблемы среды.

### 4. Релиз 
При готовности релиза девопс настраивает и запускает продуктовый экземпляр среды и продукта. Подключает их к процессам мониторинга, логирования, резервного копирования.
