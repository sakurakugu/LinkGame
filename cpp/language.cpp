#include "language.h"

#include <QGuiApplication>

// 使用 DefaultValues 中的语言列表
const QList<QPair<QString, QString>> Language::languageList = DefaultValues::languageList;

/**
 * @brief Language 类的构造函数
 * @param parent 父对象
 */
Language::Language(QObject *parent) : QObject(parent), currentLanguage_("zh_CN") {
    // 初始化时加载默认语言
    loadTranslation(currentLanguage_);
}

/**
 * @brief Language 类的析构函数
 * 清理翻译器
 */
Language::~Language() {
    // 清理翻译器
    QGuiApplication::removeTranslator(&translator_);
}

/**
 * @brief 获取当前语言
 * @return 当前语言的字符串
 */
QString Language::currentLanguage() const {
    return currentLanguage_;
}

/**
 * @brief 设置当前语言
 * @param language 要设置的语言字符串
 * 如果新语言与当前语言不同，则加载新的翻译文件并发出信号
 */
void Language::setCurrentLanguage(const QString &language) {
    if (currentLanguage_ != language) {
        currentLanguage_ = language;
        loadTranslation(language);
        emit languageChanged();
    }
}

/**
 * @brief 加载指定语言的翻译文件
 * @param language 要加载的语言字符串
 * 该函数会移除旧的翻译器，加载新的翻译文件，并安装新的翻译器
 */
void Language::loadTranslation(const QString &language) {
    // 移除旧的翻译器
    QGuiApplication::removeTranslator(&translator_);

    // 加载新的翻译文件
    QString translationFile = QString(":/i18n/LinkGame_%1.qm").arg(language);
    if (translator_.load(translationFile)) {
        if (QGuiApplication::installTranslator(&translator_)) {
            qDebug() << "成功加载翻译文件:" << translationFile;
        } else {
            qWarning() << "安装翻译文件失败:" << translationFile;
        }
    } else {
        qWarning() << "无法加载翻译文件:" << translationFile;
    }
}
