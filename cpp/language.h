#ifndef LANGUAGE_H
#define LANGUAGE_H

#include <QObject>
#include <QTranslator>
#include <QGuiApplication>

class Language : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY languageChanged)

public:
    explicit Language(QObject *parent = nullptr);
    ~Language();

    QString currentLanguage() const;
    void setCurrentLanguage(const QString &language);

    static const QList<QPair<QString, QString>> languageList;

signals:
    void languageChanged();

private:
    QString currentLanguage_;
    QTranslator translator_;
    void loadTranslation(const QString &language);
};

#endif // LANGUAGE_H
