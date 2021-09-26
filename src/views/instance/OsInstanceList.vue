<template>
  <a-card :bordered="false">
    <!-- 查询区域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="實例名稱">
              <a-input placeholder="请输入實例名稱" v-model="queryParam.instanceName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="鏡像名稱">
              <a-input placeholder="请输入鏡像名稱" v-model="queryParam.imgName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查询</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展开' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查询区域-END -->

    <!-- 操作按钮区域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">申請</a-button>
      <a-button type="primary"  @click="handlePowerOn" >開機</a-button>
      <a-button type="primary"  @click="handleShutDown" >關機</a-button>
      <a-button type="primary"  @click="handleRestrt" >重啓</a-button>
      <a-button type="primary"  @click="handleShowConsole" >控制臺</a-button>


<!--      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>-->
<!--      <a-button type="primary" icon="download" @click="handleExportXls('申請明細檔')">导出</a-button>-->
<!--      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">-->
<!--        <a-button type="primary" icon="import">导入</a-button>-->
<!--      </a-upload>-->
      <!-- 高级查询区域 -->
<!--      <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>删除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table区域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已选择 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>项
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无图片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下载
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">编辑</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleAdjustResource(record)">調整資源</a>
              </a-menu-item>
              <a-menu-item>
                <a @click="handleConnectVolume(record)">連接卷</a>
              </a-menu-item>
              <a-menu-item>
                <a @click="handleSeparateVolume(record)">分離卷</a>
              </a-menu-item>
              <a-menu-item>
                <a @click="handleShowConsole(record)">控制臺</a>
              </a-menu-item>
            </a-menu>
<!--            <a-menu slot="overlay">-->
<!--              <a-menu-item>-->
<!--                <a @click="handleDetail(record)">详情</a>-->
<!--              </a-menu-item>-->
<!--              <a-menu-item>-->
<!--                <a-popconfirm title="确定删除吗?" @confirm="() => handleDelete(record.id)">-->
<!--                  <a>删除</a>-->
<!--                </a-popconfirm>-->
<!--              </a-menu-item>-->
<!--            </a-menu>-->

          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-instance-modal ref="modalForm" @ok="modalFormOk"></os-instance-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import OsInstanceModal from './modules/OsInstanceModal'

  export default {
    name: 'OsInstanceList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsInstanceModal
    },
    data () {
      return {
        description: '申請明細檔管理页面',
        // 表头
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'實例名稱',
            align:"center",
            dataIndex: 'instanceName'
          },
          {
            title:'狀態',
            align:"center",
            dataIndex: 'status'
          },
          {
            title:'鏡像名稱',
            align:"center",
            dataIndex: 'imgName'
          },
          {
            title:'實例類型',
            align:"center",
            dataIndex: 'flavorName'
          },
          {
            title:'實例配置',
            align:"center",
            dataIndex: 'configureInfo'
          },
          {
            title:'IP地址',
            align:"center",
            dataIndex: 'ipAddress'
          },
          {
            title:'所屬項目',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'運行時長',
            align:"center",
            dataIndex: 'runTime'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "/openstack/osInstance/list",
          delete: "/openstack/osInstance/delete",
          deleteBatch: "/openstack/osInstance/deleteBatch",
          exportXlsUrl: "/openstack/osInstance/exportXls",
          importExcelUrl: "openstack/osInstance/importExcel",

        },
        dictOptions:{},
        superFieldList:[],
      }
    },
    created() {
    this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'instanceName',text:'實例名稱',dictCode:''})
        fieldList.push({type:'string',value:'options',text:'申請狀態',dictCode:''})
        fieldList.push({type:'string',value:'status',text:'狀態',dictCode:''})
        fieldList.push({type:'string',value:'represent',text:'描述',dictCode:''})
        fieldList.push({type:'string',value:'imgId',text:'鏡像id',dictCode:''})
        fieldList.push({type:'string',value:'isDelete',text:'刪除實例時是否刪除卷',dictCode:''})
        fieldList.push({type:'string',value:'flavorId',text:'實例類型id',dictCode:''})
        fieldList.push({type:'string',value:'runStatus',text:'運行狀態',dictCode:''})
        fieldList.push({type:'string',value:'securityName',text:'安全組',dictCode:''})
        fieldList.push({type:'string',value:'networkId',text:'網絡',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>