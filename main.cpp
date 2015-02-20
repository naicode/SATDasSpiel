#include <QApplication>
#include <QTranslator>
#include <QDebug>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QTranslator translator;

    QString locale = QLocale::system().name();

    //Note this solution is far not optimal
    //1. try loading specific
    if (!translator.load(locale,":/i18n")) {
        //2. if not use englich
        translator.load("en_US",":/i18");
    }

    app.installTranslator(&translator);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
