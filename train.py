import turicreate as tc

train_data = tc.image_analysis.load_images('data/train', with_path=True)
train_data['label'] = map(lambda p: p.split('/')[-2], train_data['path'])
#train_data.save('data/train.sframe')
# train_data.explore()

test_data = tc.image_analysis.load_images('data/test', with_path=True)
test_data['label'] = map(lambda p: p.split('/')[-2], test_data['path'])
#test_data.save('data/test.sframe')

model = tc.image_classifier.create(train_data, target='label', model='squeezenet_v1.1', max_iterations=500)
metrics = model.evaluate(test_data)
print(metrics)#['accuracy'])
model.export_coreml('YesBDTime/BDDigitsClassifier.mlmodel')

