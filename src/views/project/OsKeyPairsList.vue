<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="密鑰對名稱">
              <a-input placeholder="請輸入密鑰對名稱" v-model="queryParam.keyName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="用戶名稱">
              <a-input placeholder="請輸入用戶名稱" v-model="queryParam.userName"></a-input>
            </a-form-item>
          </a-col>
          <template v-if="toggleSearchStatus">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="專案名稱">
              <a-input placeholder="請輸入專案名稱" v-model="queryParam.projectName"></a-input>
            </a-form-item>
          </a-col>
          </template>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <!--<a-button type="primary" @click=" downFile" icon="download" style="margin-left: 8px">下載</a-button>-->
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展開' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>
   <!--   <a-button type="primary" icon="download" @click="handleExportXls('秘鑰對')">導出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">導入</a-button>
      </a-upload>-->
      <!-- 高級查詢區域 -->
    <!--  <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table區域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
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
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">編輯</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">詳情</a>
              </a-menu-item>
               <a-menu-item>
                <a @click="downFile(record)">下載私鑰</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="確定刪除嗎?" @confirm="() => handleDelete(record.id)">
                  <a>刪除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-key-pairs-modal ref="modalForm" @ok="modalFormOk"></os-key-pairs-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { httpAction, getAction } from '@/api/manage'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin} from '@/mixins/JeecgListMixin'
  import OsKeyPairsModal from './modules/OsKeyPairsModal'
  import { axios } from '@/utils/request'
  import {getFileAccessHttpUrl} from '@/api/manage';
  import { downloadFile } from '@/api/manage'

  export default {
    name: 'OsKeyPairsList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsKeyPairsModal
    },
    data () {
      return {
        description: '秘鑰對管理頁面',
        // 表頭
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
            title:'密鑰對名稱',
            align:"center",
            dataIndex: 'keyName'
          },

          {
            title:'專案名稱',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'指紋',
            align:"center",
            dataIndex: 'fingerprint'
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
          list: "/openstack/osKeyPairs/list",
          delete: "/openstack/osKeyPairs/delete",
          deleteBatch: "/openstack/osKeyPairs/deleteBatch",
          exportXlsUrl: "/openstack/osKeyPairs/exportXls",
          importExcelUrl: "openstack/osKeyPairs/importExcel",
          getPrivateKey: "openstack/osKeyPairs/getPrivateKey",

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
      downFile(record){
        const that = this;
        this.model = Object.assign({}, record);
        let keyName = this.model.keyName;
        debugger
        downloadFile(this.url.getPrivateKey,keyName+'.pem',this.model)
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'keyName',text:'密鑰對名稱',dictCode:''})
        fieldList.push({type:'string',value:'userName',text:'用戶名稱',dictCode:''})
        fieldList.push({type:'string',value:'projectName',text:'專案名稱',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>