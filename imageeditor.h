#ifndef IMAGEEDITOR_H
#define IMAGEEDITOR_H

#include <QObject>
#include <QImage>
#include <QUrl>
#include <QQmlEngine>
#include <QVector>

class ImageEditor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString originalImagePath READ originalImagePath WRITE setOriginalImagePath NOTIFY originalImagePathChanged)
    Q_PROPERTY(QString modifiedImagePath READ modifiedImagePath WRITE setModifiedImagePath NOTIFY modifiedImagePathChanged)
    Q_PROPERTY(int selectedRow READ selectedRow WRITE setSelectedRow NOTIFY selectedRowChanged)
    Q_PROPERTY(QString binaryPattern READ binaryPattern WRITE setBinaryPattern NOTIFY binaryPatternChanged)
    Q_PROPERTY(int imageWidth READ imageWidth NOTIFY imageWidthChanged)
    Q_PROPERTY(int imageHeight READ imageHeight NOTIFY imageHeightChanged)
    Q_PROPERTY(bool hasImage READ hasImage NOTIFY hasImageChanged)

public:
    explicit ImageEditor(QObject *parent = nullptr);
    
    // Property getters
    QString originalImagePath() const { return m_originalImagePath; }
    QString modifiedImagePath() const { return m_modifiedImagePath; }
    int selectedRow() const { return m_selectedRow; }
    QString binaryPattern() const { return m_binaryPattern; }
    int imageWidth() const { return m_imageWidth; }
    int imageHeight() const { return m_imageHeight; }
    bool hasImage() const { return m_hasImage; }
    
    // Property setters
    void setOriginalImagePath(const QString &path);
    void setModifiedImagePath(const QString &path);
    void setSelectedRow(int row);
    void setBinaryPattern(const QString &pattern);

public slots:
    Q_INVOKABLE bool loadImage(const QString &filePath);
    Q_INVOKABLE void processImage();
    Q_INVOKABLE bool saveModifiedImage(const QString &filePath);

signals:
    void originalImagePathChanged();
    void modifiedImagePathChanged();
    void selectedRowChanged();
    void binaryPatternChanged();
    void imageWidthChanged();
    void imageHeightChanged();
    void hasImageChanged();

private:
    QString m_originalImagePath;
    QString m_modifiedImagePath;
    int m_selectedRow;
    QString m_binaryPattern;
    int m_imageWidth;
    int m_imageHeight;
    bool m_hasImage;
    
    QImage m_originalImage;
    QImage m_modifiedImage;
    
    // 3D matrix to store image data [height][width][rgb]
    QVector<QVector<QVector<int>>> m_imageData;
    
    void setImageWidth(int width);
    void setImageHeight(int height);
    void setHasImage(bool hasImage);
    
    QString cleanFilePath(const QString &path) const;
    bool saveImageData(const QString &filePath);
    void convertImageToMatrix();
    void convertMatrixToImage();
    bool isValidBinaryPattern(const QString &pattern) const;
};

#endif // IMAGEEDITOR_H