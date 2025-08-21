#ifndef LANGUAGE_H
#define LANGUAGE_H

#include "default_value.h"

#include <QTranslator>

class Language : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY
                   languageChanged) // 定义一个属性 currentLanguage，用于获取和设置当前语言

  public:
    explicit Language(QObject *parent = nullptr); // 构造函数
    ~Language();

    QString currentLanguage() const;                  // 获取当前语言
    void setCurrentLanguage(const QString &language); // 设置当前语言

    static const QList<QPair<QString, QString>> languageList; // 语言列表，包含语言名称和对应的翻译文件名

  signals:
    void languageChanged(); // 语言改变时发出信号

  private:
    QString currentLanguage_;                      // 当前语言
    QTranslator translator_;                       // 翻译器对象，用于加载和应用翻译文件
    void loadTranslation(const QString &language); // 加载翻译文件
};

#endif // LANGUAGE_H
