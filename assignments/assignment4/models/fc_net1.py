
        self.fc_net = nn.Sequential(
            # nn.Linear(in_features=512 * 3 * 3, out_features=TOTAL_CLASSES // 4),
            nn.Linear(in_features=64 * 5 * 5, out_features=TOTAL_CLASSES // 4),
            nn.BatchNorm1d(TOTAL_CLASSES // 4),
            nn.ReLU(inplace=True),
            nn.Linear(in_features=TOTAL_CLASSES // 4,
                      out_features=TOTAL_CLASSES // 2),
            nn.BatchNorm1d(TOTAL_CLASSES // 2),
            nn.ReLU(inplace=True),
            # nn.BatchNorm1d(TOTAL_CLASSES // 2),
            nn.Linear(in_features=TOTAL_CLASSES //
                      2, out_features=TOTAL_CLASSES)
        )