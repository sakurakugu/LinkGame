#include "language.h"

// 使用 DefaultValues 中的语言列表
const QList<QPair<QString, QString>> Language::languageList = DefaultValues::languageList;

Language::Language(QObject *parent) : QObject(parent), currentLanguage_("zh_CN") {
    // 初始化时加载默认语言
    loadTranslation(currentLanguage_);
}

Language::~Language() {
    // 清理翻译器
    QGuiApplication::removeTranslator(&translator_);
}

QString Language::currentLanguage() const {
    return currentLanguage_;
}

void Language::setCurrentLanguage(const QString &language) {
    if (currentLanguage_ != language) {
        currentLanguage_ = language;
        loadTranslation(language);
        emit languageChanged();
    }
}

void Language::loadTranslation(const QString &language) {
    // 移除旧的翻译器
    QGuiApplication::removeTranslator(&translator_);

    // 加载新的翻译文件
    QString translationFile = QString(":/qt/qml/Translated/i18n/qml_%1.qm").arg(language);
    if (translator_.load(translationFile)) {
        if (QGuiApplication::installTranslator(&translator_)) {
            qDebug() << "成功加载翻译文件:" << translationFile;
        } else {
            qWarning() << "安装翻译器失败:" << translationFile;
        }
    } else {
        qWarning() << "无法加载翻译文件:" << translationFile;
    }
}
