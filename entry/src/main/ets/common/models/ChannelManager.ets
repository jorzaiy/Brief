// 频道配置
export interface Channel {
  id: string;
  name: string;
  sourceIds: string[];
  type: 'followed' | 'hottest' | 'realtime';
}

export class ChannelManager {
  // 预定义的热门频道
  private static readonly HOTTEST_SOURCES = [
    'zhihu',
    'weibo',
    'bilibili-hot-search',
    'baidu',
    'douyin',
    'toutiao'
  ];

  // 预定义的实时频道
  private static readonly REALTIME_SOURCES = [
    'wallstreetcn-quick',
    'cls-telegraph',
    'gelonghui',
    'jin10',
    'ithome'
  ];

  // 默认关注的频道
  private static followedSources: string[] = [
    'zhihu',
    'v2ex-share',
    'github-trending-today',
    'hackernews'
  ];

  static getChannels(): Channel[] {
    return [
      {
        id: 'followed',
        name: '关注',
        sourceIds: ChannelManager.followedSources,
        type: 'followed'
      },
      {
        id: 'hottest',
        name: '最热',
        sourceIds: ChannelManager.HOTTEST_SOURCES,
        type: 'hottest'
      },
      {
        id: 'realtime',
        name: '实时',
        sourceIds: ChannelManager.REALTIME_SOURCES,
        type: 'realtime'
      }
    ];
  }

  static getFollowedSources(): string[] {
    return [...ChannelManager.followedSources];
  }

  static setFollowedSources(sourceIds: string[]): void {
    ChannelManager.followedSources = sourceIds;
  }

  static addFollowedSource(sourceId: string): void {
    if (!ChannelManager.followedSources.includes(sourceId)) {
      ChannelManager.followedSources.push(sourceId);
    }
  }

  static removeFollowedSource(sourceId: string): void {
    const index = ChannelManager.followedSources.indexOf(sourceId);
    if (index > -1) {
      ChannelManager.followedSources.splice(index, 1);
    }
  }
}
