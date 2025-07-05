#include "imageeditor.h"
#include <QDebug>
#include <QUrl>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>

ImageEditor::ImageEditor(QObject *parent)
    : QObject(parent)
    , m_selectedRow(0)
    , m_binaryPattern("01010101")
    , m_imageWidth(0)
    , m_imageHeight(0)
    , m_hasImage(false)
{
}

void ImageEditor::setOriginalImagePath(const QString &path)
{
    if (m_originalImagePath != path) {
        m_originalImagePath = path;
        emit originalImagePathChanged();
    }
}

void ImageEditor::setModifiedImagePath(const QString &path)
{
    if (m_modifiedImagePath != path) {
        m_modifiedImagePath = path;
        emit modifiedImagePathChanged();
    }
}

void ImageEditor::setSelectedRow(int row)
{
    if (m_selectedRow != row) {
        m_selectedRow = row;
        emit selectedRowChanged();
    }
}

void ImageEditor::setBinaryPattern(const QString &pattern)
{
    if (m_binaryPattern != pattern) {
        m_binaryPattern = pattern;
        emit binaryPatternChanged();
    }
}

void ImageEditor::setImageWidth(int width)
{
    if (m_imageWidth != width) {
        m_imageWidth = width;
        emit imageWidthChanged();
    }
}

void ImageEditor::setImageHeight(int height)
{
    if (m_imageHeight != height) {
        m_imageHeight = height;
        emit imageHeightChanged();
    }
}

void ImageEditor::setHasImage(bool hasImage)
{
    if (m_hasImage != hasImage) {
        m_hasImage = hasImage;
        emit hasImageChanged();
    }
}

QString ImageEditor::cleanFilePath(const QString &path) const
{
    QString cleanPath = path;
    
    // Remove file:// prefix if present
    if (cleanPath.startsWith("file://")) {
        cleanPath = cleanPath.mid(7);
    }
    
    // Handle Windows paths
#ifdef Q_OS_WIN
    if (cleanPath.startsWith("/") && cleanPath.length() > 1 && cleanPath[2] == ':') {
        cleanPath = cleanPath.mid(1);
    }
#endif
    
    return cleanPath;
}

bool ImageEditor::loadImage(const QString &filePath)
{
    QString cleanPath = cleanFilePath(filePath);
    
    qDebug() << "Loading image from:" << cleanPath;
    
    if (!QFileInfo::exists(cleanPath)) {
        qDebug() << "Image file does not exist:" << cleanPath;
        return false;
    }
    
    // Load image
    QImage image(cleanPath);
    if (image.isNull()) {
        qDebug() << "Failed to load image:" << cleanPath;
        return false;
    }
    
    // Convert to RGB format if needed
    if (image.format() != QImage::Format_RGB888) {
        image = image.convertToFormat(QImage::Format_RGB888);
    }
    
    m_originalImage = image;
    m_modifiedImage = QImage(); // Очистка модифицированного изображения
    m_imageData.clear(); // Очистка матрицы данных
    
    // Update properties
    setImageWidth(image.width());
    setImageHeight(image.height());
    setHasImage(true);
    setOriginalImagePath(cleanPath);
    
    // Convert image to 3D matrix
    convertImageToMatrix();
    
    qDebug() << "Image loaded successfully:" << image.width() << "x" << image.height();
    
    return true;
}

void ImageEditor::convertImageToMatrix()
{
    if (m_originalImage.isNull()) {
        return;
    }
    
    int width = m_originalImage.width();
    int height = m_originalImage.height();
    
    // Initialize 3D matrix [height][width][rgb]
    m_imageData.clear();
    m_imageData.resize(height);
    
    for (int y = 0; y < height; ++y) {
        m_imageData[y].resize(width);
        for (int x = 0; x < width; ++x) {
            m_imageData[y][x].resize(3);
            
            QRgb pixel = m_originalImage.pixel(x, y);
            m_imageData[y][x][0] = qRed(pixel);   // R
            m_imageData[y][x][1] = qGreen(pixel); // G
            m_imageData[y][x][2] = qBlue(pixel);  // B
        }
    }
    
    qDebug() << "Image converted to 3D matrix";
}

void ImageEditor::convertMatrixToImage()
{
    if (m_imageData.isEmpty()) {
        return;
    }
    
    int height = m_imageData.size();
    int width = m_imageData[0].size();
    
    m_modifiedImage = QImage(width, height, QImage::Format_RGB888);
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int r = qBound(0, m_imageData[y][x][0], 255);
            int g = qBound(0, m_imageData[y][x][1], 255);
            int b = qBound(0, m_imageData[y][x][2], 255);
            
            m_modifiedImage.setPixel(x, y, qRgb(r, g, b));
        }
    }
    
    qDebug() << "Matrix converted to image";
}

bool ImageEditor::isValidBinaryPattern(const QString &pattern) const
{
    if (pattern.isEmpty()) {
        return false;
    }
    
    for (const QChar &c : pattern) {
        if (c != '0' && c != '1') {
            return false;
        }
    }
    
    return true;
}

void ImageEditor::processImage()
{
    if (!m_hasImage) {
        qDebug() << "No image loaded";
        return;
    }
    
    if (m_selectedRow >= m_imageHeight || m_selectedRow < 0) {
        qDebug() << "Selected row" << m_selectedRow << "is out of bounds (height:" << m_imageHeight << ")";
        return;
    }
    
    if (!isValidBinaryPattern(m_binaryPattern)) {
        qDebug() << "Invalid binary pattern. Must contain only 0 and 1";
        return;
    }
    
    qDebug() << "Processing row" << m_selectedRow << "with pattern:" << m_binaryPattern;
    
    // Применение бинарного паттерна к выбранной строке
    int width = m_imageWidth;
    int patternLength = m_binaryPattern.length();
    
    for (int x = 0; x < width; ++x) {
        QChar patternBit = m_binaryPattern[x % patternLength];
        int colorValue = (patternBit == '1') ? 255 : 0;
        
        // Set RGB values based on binary pattern
        m_imageData[m_selectedRow][x][0] = colorValue; // R
        m_imageData[m_selectedRow][x][1] = colorValue; // G
        m_imageData[m_selectedRow][x][2] = colorValue; // B
    }
    
    // Convert matrix back to image
    convertMatrixToImage();
    
    // Save modified image to temporary file
    QString tempDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString tempPath = QDir(tempDir).filePath(QString("temp_modified_%1.png").arg(QCoreApplication::applicationPid()));
    
    if (saveImageData(tempPath)) {
        setModifiedImagePath(tempPath);
        qDebug() << "Image processed and saved to:" << tempPath;
    }
}

bool ImageEditor::saveImageData(const QString &filePath)
{
    if (m_modifiedImage.isNull()) {
        qDebug() << "No modified image to save";
        return false;
    }
    
    QString cleanPath = cleanFilePath(filePath);
    
    if (m_modifiedImage.save(cleanPath)) {
        qDebug() << "Image saved successfully:" << cleanPath;
        return true;
    } else {
        qDebug() << "Failed to save image:" << cleanPath;
        return false;
    }
}

bool ImageEditor::saveModifiedImage(const QString &filePath)
{
    return saveImageData(filePath);
}